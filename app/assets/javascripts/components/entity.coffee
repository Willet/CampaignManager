define [
  'app',
  'backbone',
  'marionette',
  'jquery',
  'underscore',
  'backbonerelational'
], (App, Backbone, Marionette, $, _, BackboneRelational) ->

  Entity = {}

  class Entity.Model extends Backbone.RelationalModel
    blacklist: ['selected',]

    viewJSON: (opts) ->
      Backbone.RelationalModel.prototype.toJSON.call(opts)

    toJSON: (opts) ->
      _.omit(@attributes, @blacklist || {})

  class Entity.Collection extends Backbone.Collection

    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  return Entity

