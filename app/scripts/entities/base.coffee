define [
  'app',
  'backbone',
  'backbone-associations',
  'jquery',
  'underscore'
], (App, Backbone, BackboneAssociations, $, _) ->

  Base = Base || {}

  class Base.Model extends Backbone.AssociatedModel
    blacklist: ['selected',]

    initialize: ->
      @isFetched = false
      @on('request', => @isFetched = true)

    viewJSON: (opts) ->
      Backbone.AssociatedModel.prototype.toJSON.apply(@, arguments)

    toJSON: (opts) ->
      _.omit(Backbone.AssociatedModel.prototype.toJSON.apply(@, arguments), @blacklist || {})

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

    parse: (data) ->
      @metadata = data['meta']
      return data['results']


  class Base.PageableCollection extends Base.Collection

    initialize: ->
      @resetPaging()
      @queryParams = {}

    setFilter: (options, noFetch) ->
      for key, val of options
        if val == ""
          delete @queryParams[key]
        else
          @queryParams[key] = val
      @reset()

      if not noFetch
        @getNextPage()

    updateSortOrder: (new_order) ->
      @queryParams = {}
      @queryParams['order'] = new_order
      @reset()
      @getNextPage()

    reset: (models, options) ->
      super(models, options)
      @resetPaging()

    resetPaging: ->
      @params =
        results: 25
      @finished = false

    fetchAll: (opts) ->
      unless @finished
        xhr = @getNextPage()
        xhr.promise().done(=>
          @fetchAll()
        )
      else
        _.defer(=>
          @collect (product) ->
            if product.get('default-image-id')
              App.request("fetch:content", product.get('store-id'), product.get("default-image-id"))
        )

    getNextPage: (opts) ->
      unless @finished || @in_progress
        @in_progress = true

        # DEFER: could do an App.request here instead ... not sure if meaningful
        #collection = new @collectionType
        #collection.model = @model
        #collection.url = @url

        params = _.extend(@queryParams, @params)

        xhr = @fetch
          data: params
          remove: false
        $.when(
          xhr
        ).done(=>
          #@add(collection.models, at: @length)
          @params['offset'] = xhr.responseJSON['meta']?['cursors']?['next']
          @finished = true unless @params['offset']
          @in_progress = false
        )
      xhr


  return Base
