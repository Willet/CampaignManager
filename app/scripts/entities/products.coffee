define [
  "entities/base",
  "backbone.uniquemodel"
], (Base) ->

  Entities = Entities || {}

  class Entities.Product extends Base.Model

    relations: [
      {
        type: Backbone.One
        key: 'default-image-id'
        relatedModel: 'Entities.Content'
        map: (data, type) ->
          new Entities.Content(id: data)
      }
    ]

    toJSON: (opts) ->
      json = _.clone(@attributes)
      json['default-image-id'] = @get('default-image-id')?.get('id')
      json

    viewJSON: (opts) ->
      json = _.clone(@toJSON())
      json['default-image-id'] = @get('default-image-id')?.viewJSON(nested: true)
      json

  Entities.Product = Backbone.UniqueModel(Entities.Product)

  class Entities.ProductCollection extends Base.Collection

    model: Entities.Product

    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts

    url: (opts) ->
      @store_id = @hasmodel?.get?('store-id') || @store_id
      _.each(opts, (m) => m.set("store-id", @store_id))
      "#{require("app").apiRoot}/stores/#{@store_id}/products"

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  class Entities.ProductPageableCollection extends Base.PageableCollection

    model: Entities.Product
    collectionType: Entities.ProductCollection

  Entities
