define [
  "components/entity"
], (Entity) ->

  class Model extends Entity.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/campaigns/#{@get('id') || ''}"

  class Collection extends Entity.Collection
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@store_id}/campaigns"
    parse: (data) ->
      data['campaigns']

  return {
    Model: Model
    Collection: Collection
  }

