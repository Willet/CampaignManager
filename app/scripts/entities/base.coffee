define [
  'backbone',
  'jquery',
  'underscore'
], (Backbone, $, _) ->

  Base = Base || {}

  class Base.Model extends Backbone.Model
    blacklist: ['selected',]

    viewJSON: (opts) ->
      _.clone(@attributes)

    toJSON: (opts) ->
      _.omit(@attributes, @blacklist || {})

    fetch: ->
      @_fetch = super(arguments...)

    save: (attrs, options = {}) ->
      save_defaults = { patch: true }
      options = _.defaults(options, save_defaults)
      super(attrs, options)

    sync: ->
      @_fetch = super(arguments...)

  reverseSortFn = (sortFn) ->
    (left, right) ->
      l = sortFn(left)
      r = sortFn(right)

      if l < r
        1
      else if l > r
        -1
      else
        0

  class Base.Collection extends Backbone.Collection

    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

    viewJSON: ->
      @collect((m) -> m.viewJSON())

    updateSortBy: (field, reverse = false) ->
      @comparator = (m) -> m.get(field)
      if reverse
        @comparator = reverseSortFn(@comparator)
      @sort()

    fetch: ->
      @_fetch = super(arguments...)

  return Base
