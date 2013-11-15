define [
  "app",
  "entities/base",
  "backbone.uniquemodel"
], (App, Base) ->

  Entities = Entities || {}

  class Entities.Product extends Base.Model

    relations: [
      {
        type: Backbone.One
        key: 'default-image-id'
        relatedModel: 'Entities.Content'
        map: (data, type) ->
          unless typeof data is 'object'
            content = new type({id: data})
            App.request('fetch:content', @get('store-id') || @collection.store_id, content)
          else
            content = data
          content
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
