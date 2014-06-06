define [
  "app",
  "entities/base",
  "entities",
  "underscore",
  "cloudinary"
], (App, Base, Entities, _, cloudinary) ->

  Entities = Entities || {}

  class Entities.BaseContent extends Base.Model

    relations: [
      {
        type: Backbone.Many
        key: 'tagged-products'
        collectionType: 'Entities.ProductCollection'
        relatedModel: 'Entities.Product'
      }
    ]

    types = {
      1: "images"
      2: "videos"
    }

    defaults: {
      status: 'needs-review'
      'tile-configs': []
      'tagged-products': []
    }

    initialize: ->
      super(arguments)
      @computedFields = new Backbone.ComputedFields(this)

    getPageTile: ->
      # Get the regular content tile if it exists from the list of tile-configs
      try  # hack: filter tile configs by active page
        pageId = /pages\/(\d+)/g.exec(window.location.hash)[1]
      catch e
        pageId = 0
      tileConfigs = @get('tile-configs')
      pageTile = tileConfigs.filter((m) ->
        if not (m instanceof Entities.TileConfig)
          m = new Entities.TileConfig(m, {parse: true})
        (m.get('is-content') || m.get('is-content') == 'true') and m.get('page-id') == pageId
      )
      pageTile[0]

    computed: {
      'page-tile':
        depends: ['tile-configs']
        get: (fields) ->
          return @getPageTile()

      'page-status':
        depends: ['tile-configs']
        get: (fields) ->
          if @getPageTile()
            return 'added'
          else
            return null

      'page-prioritized':
        depends: ['tile-configs']
        get: (fields) ->
          tileConfig = @getPageTile()
          if tileConfig
            return tileConfig.get('prioritized')
          else
            return false
    }

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
      attrs = data

      # make sure tagged-products exist (so that the relation exists)
      attrs = super(attrs)

      tile_configs = _.map(data['tile-configs'], (m) -> new Entities.TileConfig(m, {parse: true}))
      attrs['tile-configs'] = new Entities.TileConfigCollection(tile_configs)

      attrs

    toJSON: (options) ->
      json = super(arguments)
      if json['tagged-products']
        if json['tagged-products'] instanceof Backbone.Collection
          json['tagged-products'] = json['tagged-products'].collect((m) -> m.get('id'))
        else
          json['tagged-products'] = _.map(json['tagged-products'], (m) -> m['id'])
      if json['tile-configs']
        if json['tile-configs'] instanceof Backbone.Collection
          json['tile-configs'] = json['tile-configs'].collect((m) -> m.toJSON())
      json

    viewJSON: (opts = {}) ->
      json = _.clone(@toJSON())
      # TODO: sucks that we have to undo toJSON for relational objects
      if !opts['nested']
        if @attributes['tagged-products']
          if @get('tagged-products').collect
            json['tagged-products'] = @get('tagged-products').collect((m) -> m.viewJSON(nested: true))
      json['selected'] = @get('selected')
      if @get('original-url') && /youtube/i.test(@get('original-url'))
        json['video'] = true
        video_id = @get('original-url').match(/v=(.+)/)[1]
        json['video-embed-url'] = @get('original-url').replace(/watch\?v=/, 'embed/')
        json['video-thumbnail'] = "http://i1.ytimg.com/vi/#{video_id}/mqdefault.jpg"
      else if @get('url')
        json['images'] = @imageFormatsJSON(@get('url'))
      json

    getResizedImage: (url="", options={}) ->
      # ported from pages.utils.js
      # options: known attributes are "width" and "height"

      options.width = options.width or 240
      options.height = options.height or 480

      # New feature, undocumenated, trims background space, add :
      # for tolerance, e.g. trim: 20 (defaults to 10)
      # effect: 'trim:0'
      options = _.extend({crop: "fit", quality: 75}, options)

      url = url.replace App.CLOUDINARY_DOMAIN, ""
      $.cloudinary.url(url, options)

    imageFormatsJSON: (url) ->
      sizedef = {
        pico:
          width: 16
          height: 16
        icon:
          width: 32
          height: 32
        thumb:
          width: 50
          height: 50
        small:
          width: 100
          height: 100
        compact:
          width: 160
          height: 160
        medium:
          width: 240
          height: 240
        large:
          width: 480
          height: 480
        grande:
          width: 600
          height: 600
        "1024x1024":
          width: 1024
          height: 1024
        master:
          width: 2048
          height: 2048
      }

      # compute urls for each size
      for own size_name, size_wh of sizedef
        sizedef[size_name].url = @getResizedImage(url, {
          width: size_wh.width, height: size_wh.height
        })

      sizedef


  class Entities.ContentCollection extends Base.Collection
    model: Entities.Content

    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts

    url: (opts) ->
      @store_id = @hasmodel?.get?('store-id') || @store_id
      _.each(opts, (m) => m.set("store-id", @store_id))
      "#{App.API_ROOT}/store/#{@store_id}/content?results=25"

    parse: (data) ->
      data['results']

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  class Entities.Content extends Entities.BaseContent

    relations: [
      {
        type: Backbone.Many
        key: 'tagged-products'
        collectionType: 'Entities.ProductCollection'
        relatedModel: 'Entities.Product'
        options:
          reset: true
          parse: false
        map: (id, target) ->
          storeId = @store_id || window.App.routeModels.get('store').id
          if id instanceof Entities.Product
            return id
          if id instanceof Entities.ProductCollection
            return id
          if _.isArray(id)
            prod_array = _.map id, (pid) ->
              if pid instanceof Entities.Product
                pid
              else if _.isObject(pid)
                #new Entities.Product(pid)
                App.request('product:entity', storeId, pid.id)
              else if _.isString(pid)
                #new Entities.Product({id: pid})
                App.request('product:entity', storeId, pid)
              else
                console.error "UNHANDLED RELATIONSHIP ARRAY MAPPING CASE", pid
            return prod_array
          console.error "UNHANDLED RELATIONSHIP CASE", arguments
          null
      }
    ]

    defaults: {
      'tagged-products': []
    }

  class Entities.ContentPageableCollection extends Base.PageableCollection

    model: Entities.Content
    collectionType: Entities.ContentCollection

  Entities

