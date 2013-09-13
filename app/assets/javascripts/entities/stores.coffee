define [
  "entities/base"
], (Base) ->

  Entities = Entities || {}

  class Entities.Store extends Base.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('id')}"

  class Entities.StoreCollection extends Base.Collection

    model: Entities.Store

    url: (opts) ->
      "#{require("app").apiRoot}/stores"

    parse: (data) ->
      data['stores']

  Entities