define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: [
      {
        collectionType: "Models.Content.Collection"
        collectionKey: false
        collectionOptions: (model) -> { model: model }
        key: 'content-ids'
        relatedModel: "Models.Content.Model"
        type: Backbone.HasMany
        includeInJSON: Backbone.Model.prototype.idAttribute
      },
      {
        key: 'default-image-id'
        relatedModel: "Models.Content.Model"
        type: Backbone.HasOne
        includeInJSON: Backbone.Model.prototype.idAttribute
      }
    ]
    url: (opts) ->
      "/api/stores/#{@get('store-id')}/products/#{@get('id') || ''}"
    viewJSON: ->
      json = @toJSON()
      json['content-ids'] = @get('content-ids')?.viewJSON()
      json['default-image-id'] = @get('default-image-id')?.viewJSON()
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
      "/api/stores/#{@store_id}/products"
    parse: (data) ->
      data['products']
    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

  return {
    Model: Model
    Collection: Collection
  }

