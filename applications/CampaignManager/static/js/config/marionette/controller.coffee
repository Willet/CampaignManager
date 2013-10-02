require [
  "marionette",
], (Marionette) ->

  _.extend Backbone.Marionette.Controller::,

    setRegion: (region) ->
      @region = region