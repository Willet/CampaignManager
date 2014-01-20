require [
  "backbone"
], (Backbone) ->

  _.extend Backbone.Collection::,
    viewJSON: ->
      @collect((m) -> m.viewJSON())
