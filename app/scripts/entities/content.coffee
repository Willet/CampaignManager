define [
  "app",
  "entities/base",
  "entities",
  "underscore"
], (App, Base, Entities, _) ->

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
      tileConfigs = @get('tile-configs')
      pageTile = tileConfigs.filter((m) -> m.get('is-content') || m.get('is-content') == 'true')
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
          if id instanceof Entities.Product
            return id
          if id instanceof Entities.ProductCollection
            return id
          if _.isArray(id)
            prod_array = _.map id, (pid) ->
              if pid instanceof Entities.Product
                pid
              else if _.isObject(pid)
                new Entities.Product(pid)
              else if _.isString(pid)
                new Entities.Product({id: pid})
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

