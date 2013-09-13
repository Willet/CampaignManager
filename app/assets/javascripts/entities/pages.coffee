define [
  "entities/base"
], (Base) ->

  class Model extends Base.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/campaigns/#{@get('id') || ''}"

  class Collection extends Base.Collection

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@store_id}/campaigns"
    parse: (data) ->
      data['campaigns']

  return {
    Model: Model
    Collection: Collection
  }

