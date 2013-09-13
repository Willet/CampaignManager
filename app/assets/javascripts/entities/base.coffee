define [
  'backbone',
  'jquery',
  'underscore'
], (Backbone, $, _) ->

  Base = {}

  class Base.Model extends Backbone.Model
    blacklist: ['selected',]

    viewJSON: (opts) ->
      Backbone.Model.prototype.toJSON.call(opts)

    toJSON: (opts) ->
      _.omit(@attributes, @blacklist || {})

  class Base.Collection extends Backbone.Collection

    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  return Base