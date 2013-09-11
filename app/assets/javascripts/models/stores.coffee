define [
  "components/entity"
], (Entity) ->

  class Model extends Entity.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('id')}"

  class Collection extends Entity.Collection

    url: (opts) ->
      "#{require("app").apiRoot}/stores"

    parse: (data) ->
      data['stores']

  return {
    Model: Model
    Collection: Collection
  }

