define [
  'app',
  '../app',
  './edit_views'
], (App, ContentManager, Views) ->

  ContentManager.products ?= {}

  # TODO find out how I can change name to ContentManager.EditContent.Controller
  # TODO should I extend Marionette.Controller or App.Controllers.Base?
  class ContentManager.Controller extends App.Controllers.Base

    productListType: Views.PageProductGridItem

    initialize: (model) ->
      store = App.routeModels.get('store')
      page = App.routeModels.get('page')

      layout = new Views.editContentLayout
        model: page

      products = App.request('page:products', page)

      layout.on 'tagged-content-product'
