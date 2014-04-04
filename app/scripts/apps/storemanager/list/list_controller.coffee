define [
  'app',
  '../app',
  './list_view'
], (App, StoreManager, Views) ->

  StoreManager.List ?= {}

  class StoreManager.List.Controller extends App.Controllers.Base

    initialize: ->
      # Endpoint implicitly doesn't allow me to request stores
      # I don't belong to
      self = this
      stores = App.request "store:all"

      App.execute 'when:fetched', stores, ->
        view = new Views.StoreIndex
          model: stores

        self.show view
