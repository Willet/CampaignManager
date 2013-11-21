define [
  "app",
  "entities/base",
  "entities/products",
  "underscore",
  "backbone.uniquemodel"
], (App, Base, Entities, _) ->

  Entities = Entities || {}

  class Entities.Content extends Base.Model

    relations: [
      {
        type: Backbone.Many
        key: 'tagged-products'
        collectionType: 'Entities.ProductCollection'
        map: (fids, type) ->
          # see https://github.com/dhruvaray/backbone-associations/issues/79
          # a pull request I opened up to address how insane this code is
          # in what should be a simple case
          collection = type
          fids = if _.isArray(fids) then fids else [fids]
          type = if (type instanceof Backbone.Collection) then type.model else type
          data = _.map fids, (fid) ->
            if fid instanceof Backbone.Model
              fid
            else
              new Entities.Product({id: fid})

          if collection instanceof Backbone.Collection
            return data
          else
            return new type(data)
      }
    ]

    types = {
      1: "images"
      2: "videos"
    }

    defaults: {
      active: true,
      approved: false
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
      attrs = data

      # make sure tagged-products exist (so that the relation exists)
      unless attrs['tagged-products']
        attrs['tagged-products'] = []
      attrs = super(attrs)
      attrs['active'] = if (attrs['active'] == "true" || attrs['active'] == true) then true else false
      attrs['approved'] = if (attrs['approved'] == "true" || attrs['approved'] == true) then true else false

      attrs

    toJSON: (options) ->
      json = _.clone(@attributes)
      if json['tagged-products']
        if json['tagged-products'] instanceof Backbone.Collection
          json['tagged-products'] = json['tagged-products'].collect((m) -> m.get('id'))
        else
          json['tagged-products'] = _.map(json['tagged-products'], (m) -> m.get('id'))
      json['active'] = if (json['active'] == "true" || json['active'] == true) then true else false
      json['approved'] = if (json['approved'] == "true" || json['approved'] == true) then true else false
      json

    viewJSON: (opts = {}) ->
      json = _.clone(@toJSON())
      # TODO: sucks that we have to undo toJSON for relational objects
      if !opts['nested']
        if @attributes['tagged-products']
          if @get('tagged-products').collect
            json['tagged-products'] = @get('tagged-products').collect((m) -> m.viewJSON(nested: true))
      json['selected'] = @get('selected')
      json['active'] = if (json['active'] == "true" || json['active'] == true) then true else false
      json['approved'] = if (json['approved'] == "true" || json['approved'] == true) then true else false
      @set('active', json['active'])
      @set('approved', json['approved'])
      if @get('active')
        if @get('approved')
          json['approved'] = true
          json['state'] = 'approved'
        else
          json['new'] = true
          json['state'] = 'new'
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

  #Entities.Content = Backbone.UniqueModel(Entities.Content)

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

  class Entities.ContentPageableCollection extends Base.PageableCollection

    model: Entities.Content
    collectionType: Entities.ContentCollection

  Entities

