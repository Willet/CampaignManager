define [
  "components/entity"
], (Entity) ->

  class Model extends Entity.Model

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

    viewJSON: ->
      json = @toJSON()
      json['product-ids'] = @get('product-ids')?.toJSON()
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
        json['images'] = {
          pico:
            width: 16
            height: 16
            url: @get('remote-url').replace('master', 'pico')
          icon:
            width: 32
            height: 32
            url: @get('remote-url').replace('master', 'icon')
          thumb:
            width: 50
            height: 50
            url: @get('remote-url').replace('master', 'thumb')
          small:
            width: 100
            height: 100
            url: @get('remote-url').replace('master', 'small')
          compact:
            width: 160
            height: 160
            url: @get('remote-url').replace('master', 'compact')
          medium:
            width: 240
            height: 240
            url: @get('remote-url').replace('master', 'medium')
          large:
            width: 480
            height: 480
            url: @get('remote-url').replace('master', 'large')
          grande:
            width: 600
            height: 600
            url: @get('remote-url').replace('master', 'grande')
          "1024x1024":
            width: 1024
            height: 1024
            url: @get('remote-url').replace('master', '1024x1024')
          master:
            width: 2048
            height: 2048
            url: @get('remote-url')
        }
      json

  class Collection extends Entity.Collection
    model: Model

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


  class PageCollection extends Entity.Collection
    model: Model

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

  class PageableCollection extends Entity.Collection
    model: Model

    initialize: ->
      @resetPaging()

    resetPaging: ->
      @params = {
        results: 25
      }
      @finished = false

    getNextPage: (opts) ->
      unless @finished
        collection = new PageCollection(queryParams: @params)
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

  ###
  class PageableCollection extends Backbone.PageableCollection
    model: Model

    initialize: (opts) ->
      super(arguments)

    url: (opts) ->
      "#{require("app").apiRoot}/stores/126/content"

    lastPageId: null

    mode: "infinite"
    queryParams:
      pageSize: "results"
      "start-id": ->
        @lastPageId
      currentPage: null
      totalPages: null
      totalRecords: null

    lastData: null

    parseRecords: (data) ->
      @lastData = @lastData || data['content']

    parseLinks: (data) ->
      oldLastPageId = @lastPageId
      @lastPageId = data['last-id']+1
      links = {}
      if oldLastPageId
        links['prev'] = "#{require("app").apiRoot}/stores/126/content?start-id=#{oldLastPageId}"
      else
        links['first'] = "#{require("app").apiRoot}/stores/126/content"
      if @lastPageId
        links['next'] = "#{require("app").apiRoot}/stores/126/content?start-id=#{@lastPageId}"
      console.log links
      return links

    viewJSON: ->
      @collect((m) -> m.viewJSON())
  ###

  return {
    Model: Model
    Collection: Collection
    PageableCollection: PageableCollection
  }

