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
      }
    ]
    url: (opts) ->
      "/api/stores/#{@get('store_id')}/products/#{@get('id') || ''}"

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "/api/stores/#{@store_id}/products"
    parse: (data) ->
      data['products']

  return {
    Model: Model
    Collection: Collection
  }

