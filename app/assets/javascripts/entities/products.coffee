define [
  "entities/base"
], (Base) ->

  Entities = Entities || {}

  class Entities.Product extends Base.Model

    url: (opts) ->
      "#{require("app").apiRoot}/stores/#{@get('store-id')}/products/#{@get('id') || ''}"

    viewJSON: ->
      json = @toJSON()
      json['content-ids'] = @get('content-ids')?.viewJSON()
      json['default-image-id'] = @get('default-image-id')?.viewJSON()
      json

  class Entities.ProductCollection extends Base.Collection

    model: Entities.Product

    initialize: (models, opts) ->
      @hasmodel = opts['model'] if opts

    url: (opts) ->
      @store_id = @hasmodel?.get?('store-id') || @store_id
      _.each(opts, (m) => m.set("store-id", @store_id))
      "#{require("app").apiRoot}/stores/#{@store_id}/products"

    parse: (data) ->
      data['products']

    viewJSON: ->
      @collect((m) -> m.viewJSON())

  return {
    Model: Entities.Product
    Collection: Entities.ProductCollection
  }
