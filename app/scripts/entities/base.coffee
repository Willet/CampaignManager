define [
  'app',
  'backbone',
  'backbone-associations',
  'backbone.computedfields',
  'jquery',
  'underscore'
], (App, Backbone, BackboneAssociations, BackboneComputedFields, $, _) ->

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

      # only save changed attributes, unless specified
      if not attrs
        attrs = @changed

      # cannot save empty string, so convert to null
      attrs = _.clone attrs
      keys = _.keys attrs
      _.each keys, (key) ->
        if _.isString(attrs[key])
          attrs[key] = attrs[key] || null

      # same as usual otherwise
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

    setFilter: (options, fetch=true) ->
      @queryParams = {}
      for key, val of options
        if val == ""
          delete @queryParams[key]
        else
          @queryParams[key] = val
      @reset()

      # Seems to be some condition with associated models where it can't call
      # `fetchAll` or `getNextPage` after `setFilter` because it is in the
      # middle of finishing the `setFilter` call
      if fetch
        @fetch('data': @queryParams)


  class Base.PageableCollection extends Base.Collection

    initialize: (models, params = { order: "descending" }) ->
      @resetPaging()
      @queryParams = params

    setFilter: (options, fetch=true) ->
      @queryParams = {}
      for key, val of options
        if val == ""
          delete @queryParams[key]
        else
          @queryParams[key] = val
      @reset()


      # Seems to be some condition with associated models where it can't call
      # `fetchAll` or `getNextPage` after `setFilter` because it is in the
      # middle of finishing the `setFilter` call
      if fetch
        @getNextPage()

    reset: (models, options) ->
      @resetPaging()
      super(models, options)

    resetPaging: ->
      @params =
        results: 25
      @finished = false

    fetchAll: (opts={}) ->
      unless @finished
        xhr = @getNextPage(opts)
        xhr.promise().done(=>
          @fetchAll()
        )

    getNextPage: (opts={}) ->
      unless @finished || @in_progress
        @in_progress = true

        # DEFER: could do an App.request here instead ... not sure if meaningful
        #collection = new @collectionType
        #collection.model = @model
        #collection.url = @url
        params = _.extend(@queryParams, @params, opts)

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
          # We trigger a fail if we have no results
          if @params['results'].length == 0 or not @params['offset']
            @trigger 'fail'
        ).fail(=>
          # Need to signal fetching has ended on error
          @finished = true
          @in_progress = false
          @trigger 'fail' # Need the explicit call in case of fail
        )
      xhr


  return Base
