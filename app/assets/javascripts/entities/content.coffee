define [
  "entities/base",
  "entities/products"
], (Base, ProductEntities) ->

  Entities = Entities || {}

  class Entities.Content extends Base.Model

    initialize: (opts, relatedOptions) ->
      if relatedOptions && relatedOptions['store-id']
        @set('store-id', relatedOptions['store-id'])

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/content/#{@get('id') || ''}"

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

    tagNewProduct: (product) ->

    parse: (data) ->
      attrs = data
      if data['tagged-products']
        attrs['tagged-products'] = new ProductEntities.Collection(data['tagged-products'])
      attrs

    toJSON: ->
      json = _.clone(@attributes)
      if json['tagged-products']
        json['tagged-products'] = @attributes['tagged-products'].toJSON()
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
      else if @get('remote-url')
        json['images'] = @imageFormatsJSON(@get('remote-url'))
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
      "#{require("app").apiRoot}/stores/#{@store_id}/content?results=21"

    parse: (data) ->
      data['content']

    viewJSON: ->
      @collect((m) -> m.viewJSON())


  class Entities.ContentPageCollection extends Base.Collection
    model: Entities.Content

    initialize: (opts) ->
      @queryParams = opts['queryParams']

    parse: (data) ->
      @params = @parseParams(data)
      @parseData(data)

    parseParams: (data) ->
      result = {
        "results": 25
      }
      result['start-id'] = data['last-id'] if data['last-id']
      result

    parseData: (data) ->
      data['content']

    url: (opts) ->
      # TODO: correct URL
      if @queryParams
        params = "?" + $.param(@queryParams)
      else
        params = ""
      "#{require("app").apiRoot}/stores/126/content" + params

  class Entities.ContentPageableCollection extends Base.Collection
    model: Entities.Content

    initialize: ->
      @resetPaging()
      @queryParams = {}

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
      @params = {
        results: 25
      }
      @finished = false

    getNextPage: (opts) ->
      unless @finished
        collection = new Entities.ContentPageCollection(queryParams: _.extend(@queryParams, @params))
        xhr = collection.fetch()
        $.when(
          xhr
        ).done(=>
          @add(collection.models, at: @length)
          @params = collection.params
          @finished = true unless @params['start-id']
        )
      xhr

    url: ->
      "#{require("app").apiRoot}/stores/126/content"

  Entities

