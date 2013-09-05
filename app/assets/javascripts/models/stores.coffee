define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: []
    url: (opts) ->
      "#{SecondFunnel.apiRoot}/stores/#{@get('id')}"

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "#{SecondFunnel.apiRoot}/stores"
    parse: (data) ->
      data['stores']

  return {
    Model: Model
    Collection: Collection
  }

