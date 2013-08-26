define ["backbone", "backbonerelational"], (Backbone, BackboneRelational)->

  class Model extends Backbone.RelationalModel
    relations: [
      {
        collectionType: "Models.Products.Collection"
        collectionKey: false
        collectionOptions: (model) -> { model: model }
        key: 'product-ids'
        relatedModel: "Models.Products.Model"
        type: Backbone.HasMany
      }
    ]
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
    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts
    url: (opts) ->
      # TODO: this is a hack because relational calls this
      #       to check if multi-function
      @store_id = @hasmodel?.get?('store_id') || @store_id
      _.each(opts, (m) => m.set("store_id", @store_id))
      "/api/stores/#{@store_id}/content"
    parse: (data) ->
      data['content']
    comparator: (model) ->
      # auto-sort by id on grabbing the collection
      model.get("id")

  return {
    Model: Model
    Collection: Collection
  }

