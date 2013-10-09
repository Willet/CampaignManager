define [
  './app',
  'marionette',
  'components/views/not_implemented'
], (Analytics, Marionette, NotImplemented) ->

  class Analytics.Controller extends Marionette.Controller

    analyticsIndex: (store_id) ->
      layout = new NotImplemented()
      console.log "not implemented"
      App.layout.show layout

  Analytics
