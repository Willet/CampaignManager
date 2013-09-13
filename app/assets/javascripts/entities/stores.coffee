define [
  "entities/base"
], (Base) ->

  class Model extends Base.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('id')}"

  class Collection extends Base.Collection

    url: (opts) ->
      "#{require("app").apiRoot}/stores"

    parse: (data) ->
      data['stores']

  return {
    Model: Model
    Collection: Collection
  }

