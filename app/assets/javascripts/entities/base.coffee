define [
  'backbone',
  'jquery',
  'underscore',
  'backboneuniquemodel'
], (Backbone, $, _) ->

  Base = Base || {}

  class Base.Model extends Backbone.Model
    blacklist: ['selected',]

    viewJSON: (opts) ->
      _.clone(@attributes)

    toJSON: (opts) ->
      _.omit(@attributes, @blacklist || {})

    fetch: ->
      @_fetch = super()

  class Base.Collection extends Backbone.Collection

    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

    viewJSON: ->
      @collect((m) -> m.viewJSON())

    fetch: ->
      @_fetch = super(arguments...)

  return Base