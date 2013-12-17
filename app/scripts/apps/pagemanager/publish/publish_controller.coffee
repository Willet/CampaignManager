define [
  'app',
  '../app',
  './publish_view'
], (App, PageManager, Views) ->

  PageManager.Publish ?= {}

  class PageManager.Publish.Controller extends App.Controllers.Base

    initialize: ->
      page = App.routeModels.get 'page'
      store = App.routeModels.get 'store'
      layout = new Views.PublishPage
        model: page
        store: store

      layout.on 'publish', () ->
        req = App.request 'page:publish', page
        req.done (data) ->
          # crude as it is, this is also an option
          # window.open('http://' + data.result.bucket_name + '/' + data.result.s3_path);
          App.navigate('/' + store.get('id') + '/pages/' + page.get('id') + '/preview', { trigger: true })
        req.fail () ->
          # TODO: move this into the view (as it should be)
          layout.$('.publish.button').text('Publish Page')
          layout.$(layout.fail.el).show()

      App.execute 'when:fetched', [store, page], () =>
        if App.ENVIRONMENT is 'DEV'
          store.set('public-base-url', store.get('public-base-url', '').replace(/(https?:\/\/)/, '$1dev-'))
        else if App.ENVIRONMENT is 'TEST'
          store.set('public-base-url', store.get('public-base-url', '').replace(/(https?:\/\/)/, '$1test-'))
        @show layout

