define [
  'app',
  './app',
  './views',
  'marionette'
], (App, StoreManager, Views, Marionette) ->

  class StoreManager.Controller extends Marionette.Controller

    storeIndex: () ->
      new StoreManager.List.Controller
        region: @region

  StoreManager
