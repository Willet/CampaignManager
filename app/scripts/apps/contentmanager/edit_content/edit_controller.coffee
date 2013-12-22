define [
  'app',
  '../app',
  'entities/content'
  './edit_views'
], (App, ContentManager, ContentEntities, Views) ->

  class ContentManager.Controller extends App.Controllers.Base

    initialize: (model) ->
      store = App.routeModels.get('store')
      page = App.routeModels.get('page')
      @layout = new Views.EditContentLayout
        model: model

      @layout.on 'closeEditView', =>
        @layout.close()

      App.modal.show @layout

  ContentManager.Controller
