define [
  "backbone",
  "backbonerelational",
  "components/entity"
], (Backbone, BackboneRelational, Entity) ->

  class Model extends Entity.Model
    relations: []
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/campaigns/#{@get('id') || ''}"

  Model.setup()

  class Collection extends Entity.Collection
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@store_id}/campaigns"
    parse: (data) ->
      data['campaigns']

  return {
    Model: Model
    Collection: Collection
  }

