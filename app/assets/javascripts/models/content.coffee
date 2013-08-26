define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: [
      {
        collectionType: "Models.Products.Collection"
        collectionKey: false
        collectionOptions: (model) -> { model: model }
        key: 'product-ids'
        relatedModel: "Models.Products.Model"
        type: Backbone.HasMany
        includeInJSON: Backbone.Model.prototype.idAttribute
      }
    ]
    url: (opts) ->
      "/api/stores/#{@get('store-id')}/content/#{@get('id') || ''}"

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

    viewJSON: ->
      json = @toJSON()
      json['product-ids'] = @get('product-ids').toJSON()
      if @get('remote-url')
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

  Model.setup()

  class Collection extends Backbone.Collection
    model: Model
    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts
    url: (opts) ->
      # TODO: this is a hack because relational calls this
      #       to check if multi-function
      @store_id = @hasmodel?.get?('store-id') || @store_id
      _.each(opts, (m) => m.set("store-id", @store_id))
      "/api/stores/#{@store_id}/content"
    parse: (data) ->
      data['content']
    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")
    viewJSON: ->
      @collect((m) -> m.viewJSON())

  return {
    Model: Model
    Collection: Collection
  }

