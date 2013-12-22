define [
  'app',
  '../app',
  'entities/content'
  './edit_views'
], (App, ContentManager, ContentEntities, Views) ->

  class ContentManager.Controller extends App.Controllers.Base

    productListType: Views.PageProductGridItem

    initialize: (model) ->
      store = App.routeModels.get('store')
      page = App.routeModels.get('page')
#      smartContent = new ContentEntities.ProductAwareContent(
#        model.toJSON()
#      )
#      App.request('fetch:content', store.id, smartContent)
      @layout = new Views.EditContentLayout
        model: model

      @layout.on 'closeEditView', =>
        @layout.close()

      App.modal.show @layout

  ContentManager.Controller
