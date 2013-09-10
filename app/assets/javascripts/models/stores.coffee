define [
  "backbone",
  "backbonerelational"
], (Backbone, BackboneRelational) ->

  class Model extends Backbone.RelationalModel
    relations: []
    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('id')}"

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "#{require("app").apiRoot}/stores"
    parse: (data) ->
      data['stores']

  return {
    Model: Model
    Collection: Collection
  }

