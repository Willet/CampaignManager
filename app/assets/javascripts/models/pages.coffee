define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: []
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/campaigns/#{@get('id') || ''}"

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@store_id}/campaigns"
    parse: (data) ->
      data['campaigns']

  return {
    Model: Model
    Collection: Collection
  }

