define [
  'app',
  '../app',
  './preview_view'
], (App, PageManager, Views) ->

  PageManager.Preview ?= {}

  class PageManager.Preview.Controller extends App.Controllers.Base

    initialize: ->
      page = App.routeModels.get 'page'
      store = App.routeModels.get 'store'
      App.execute 'when:fetched', store, =>
        $.ajax(data || getBucketInfo(page, store))
          .done(() =>
            view = new Views.PagePreview({ model: new Entities.Model(data) })
            @show view
          )
          .fail(() =>
            # S3 emits 404 if page not generated
            # TODO: there is a cleaner way to do this
            App.navigate('/' + store.get('id') + '/pages/' + page.get('id') + '/publish', { trigger: true })
          )

    getBucketInfo: (page, store) ->
      # existence of bucket name is a signal that the page was successfully created.
      # mock out page generator result, making sure
      # that the urls match CM's format
      domain = store.get('public-base-url')
              .replace(/https?:\/\//i, '')
              .replace(/\/$/, '')
      path = page.get('url')
      if path.substring(0, 1) is '/'
        path = path.substring(1)
      if path.substring(0, 1) is '/'
        path = path.substring(1)

      if App.ENVIRONMENT is 'DEV'
        domain = 'dev-' + domain
      else if App.ENVIRONMENT is 'TEST'
        domain = 'test-' + domain

      return {
        'result': {
          'bucket_name': domain,
          's3_path': path
        },
        'url': 'http://' + domain + '/' + path
      }

