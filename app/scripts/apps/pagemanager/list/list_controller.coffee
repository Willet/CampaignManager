define [
  'app',
  '../app',
  './list_view'
], (App, PageManager, Views) ->

  PageManager.List ?= {}

  class PageManager.List.Controller extends App.Controllers.Base

    initialize: ->
      store = App.routeModels.get 'store'
      pages = App.request 'page:all', store

      allPages = null
      App.execute 'when:fetched', pages, ->
        allPages = _.clone pages.models

      view = new Views.PageIndex
        model: pages
        'store': store

      view.on 'change:filter', (filter) ->
        filteredPages = _.filter allPages, (m) ->
          new RegExp(filter, 'i').test(m.get('name') || '')
        pages.reset filteredPages

      view.on 'change:sort-order', (order) ->
        pages.updateSortBy(order, order is 'last-modified')

      view.on 'edit-most-recent', ->
        mostRecent = _.max allPages, (m) -> m.get('last-modified');
        App.navigate '/' + store.get('id') + '/pages/' + mostRecent.id, { trigger: true }

      view.on 'new-page', ->
        App.navigate('/' + store.get('id') + '/pages/new', { trigger: true })

      @show view