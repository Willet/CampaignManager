define [
  'backbone',
  'marionette',
  'jquery',
  'underscore'
], (Backbone, Marionette, $, _) ->

  Entity = {}

  class Entity.Model extends Backbone.Model
    blacklist: ['selected',]

    viewJSON: (opts) ->
      Backbone.Model.prototype.toJSON.call(opts)

    toJSON: (opts) ->
      _.omit(@attributes, @blacklist || {})

  class Entity.Collection extends Backbone.Collection

    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  return Entity

