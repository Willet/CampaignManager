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
      layout = new Views.PagePreview
        model: page
        store: store

      App.execute 'when:fetched', [store, page], () =>
        @show layout
