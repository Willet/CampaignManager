define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: []
    url: (opts) ->
      "/api/stores/#{@get('store_id')}/content/#{@get('id') || ''}"

    reject: ->
      @save(
        active: false
        approved: false
      )

    approve: ->
      @save(
        active: true
        approved: true
      )

  Model.setup()

  class Collection extends Backbone.Collection
    url: (opts) ->
      "/api/stores/#{@store_id}/content"
    parse: (data) ->
      data['content']

  return {
    Model: Model
    Collection: Collection
  }

