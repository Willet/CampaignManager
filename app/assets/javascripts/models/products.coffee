define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: []
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

