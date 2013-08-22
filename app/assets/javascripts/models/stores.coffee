define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: []
    url: (opts) ->
      "/api/stores/#{@get('id')}"

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "/api/stores"
    parse: (data) ->
      data['stores']

  return {
    Model: Model
    Collection: Collection
  }

