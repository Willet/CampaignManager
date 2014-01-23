define [
  'app',
  '../app',
  'entities/content'
  './edit_view'
], (App, ContentManager, ContentEntities, Views) ->

  class ContentManager.Controller extends App.Controllers.Base

    initialize: (model) ->
      store = App.routeModels.get('store')
      page = App.routeModels.get('page')
      @view = new Views.EditContentView
        model: model

      @view.on 'closeEditView', =>
        @view.close()

      @view.on 'captionEditView', =>
        @view.onCaptionChange()

      App.modal.show @view

  ContentManager.Controller
