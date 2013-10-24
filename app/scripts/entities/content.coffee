define [
  "app",
  "entities/base",
  "entities/products",
  "underscore"
], (App, Base, Entities, _) ->

  Entities = Entities || {}

  class Entities.Content extends Base.Model

    types = {
      1: "images"
      2: "videos"
    }

    reject: ->
      @save(
        active: false
        approved: false
      )

    approve: ->
      @save(
        active: true
        approved: true
      )

    undecided: ->
      @save(
        active: true
        approved: false
      )

    tag: (tags) ->
      unless _.isArray(tags) or _.isNull(tags)
        tags = [tags]

      @save(
        tags: tags
      )

    # TODO: should be a better way
    # since this belongs to collections from different paths
    # e.g. from inside the page, need to override to always use this path
    # this allows .save() to work.
    url: ->
      "#{App.API_ROOT}/store/#{@get('store-id')}/content/#{@get('id')}"

    parse: (data) ->
      attrs = _.clone(data)
      attrs['active'] = if data['active'] == "true" then true else false
      attrs['approved'] = if data['approved'] == "true" then true else false
      attrs['tagged-products'] = []
      _.each data['tagged-products'], (product_id) ->
        product = App.request("product:entity", attrs['store-id'], product_id)
        attrs['tagged-products'].push(product)
      attrs['tagged-products'] = new Entities.ProductCollection(attrs['tagged-products'])

      # trigger an event when related models are fetched
      xhrs = _.map(attrs['tagged-products'].models, ((product) -> product._fetch))
      $.when.apply($, xhrs).done(=> @trigger('related-fetched'))

      attrs

    toJSON: ->
      json = super()
      if @attributes['tagged-products']
        json['tagged-products'] = @get('tagged-products').collect((m) -> m.get("id"))
      json

    viewJSON: ->
      json = @toJSON()
      json['selected'] = @get('selected')
      if @get('active')
        if @get('approved')
          json['approved'] = true
          json['state'] = 'approved'
        else
          json['undecided'] = true
          json['state'] = 'undecided'
      else
        json['rejected'] = true
        json['state'] = 'rejected'
      if @get('original-url') && /youtube/i.test(@get('original-url'))
        json['video'] = true
        video_id = @get('original-url').match(/v=(.+)/)[1]
        json['video-embed-url'] = @get('original-url').replace(/watch\?v=/, 'embed/')
        json['video-thumbnail'] = "http://i1.ytimg.com/vi/#{video_id}/mqdefault.jpg"
      else if @get('url')
        json['images'] = @imageFormatsJSON(@get('url'))
      json

    imageFormatsJSON: (url) ->
      {
        pico:
          width: 16
          height: 16
          url: url.replace('master', 'pico')
        icon:
          width: 32
          height: 32
          url: url.replace('master', 'icon')
        thumb:
          width: 50
          height: 50
          url: url.replace('master', 'thumb')
        small:
          width: 100
          height: 100
          url: url.replace('master', 'small')
        compact:
          width: 160
          height: 160
          url: url.replace('master', 'compact')
        medium:
          width: 240
          height: 240
          url: url.replace('master', 'medium')
        large:
          width: 480
          height: 480
          url: url.replace('master', 'large')
        grande:
          width: 600
          height: 600
          url: url.replace('master', 'grande')
        "1024x1024":
          width: 1024
          height: 1024
          url: url.replace('master', '1024x1024')
        master:
          width: 2048
          height: 2048
          url: url
      }


  class Entities.ContentCollection extends Base.Collection
    model: Entities.Content

    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts

    url: (opts) ->
      @store_id = @hasmodel?.get?('store-id') || @store_id
      _.each(opts, (m) => m.set("store-id", @store_id))
      "#{App.API_ROOT}/store/#{@store_id}/content?results=21"

    parse: (data) ->
      data['results']

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  class Entities.ContentPageableCollection extends Base.Collection
    model: Entities.Content

    initialize: ->
      @resetPaging()
      @queryParams = {}

    selectAll: ->
      @collect((m) -> m.set('selected', true))

    unselectAll: ->
      @collect((m) -> m.set('selected', false))

    setFilter: (options) ->
      for key, val of options
        if val == ""
          delete @queryParams[key]
        else
          @queryParams[key] = val
      @reset()
      @getNextPage()

    updateSortOrder: (new_order) ->
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

    getNextPage: (opts) ->
      unless @finished || @in_progress
        @in_progress = true

        # DEFER: could do an App.request here instead ... not sure if meaningful
        collection = new Entities.ContentCollection
        params = _.extend(@queryParams, @params)
        collection.url = @url

        xhr = collection.fetch
          data: params
          reset: true

        $.when(
          xhr
        ).done(=>
          @add(collection.models, at: @length)
          @params['offset'] = xhr.responseJSON['meta']?['cursors']?['next']
          @finished = true unless @params['offset']
          @in_progress = false
        )
      xhr

  Entities

