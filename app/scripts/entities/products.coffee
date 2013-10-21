define [
  "entities/base",
  "backbone.uniquemodel"
], (Base) ->

  Entities = Entities || {}

  class Entities.Product extends Base.Model

    viewJSON: ->
      json = super()
      json['content-ids'] = @get('content-ids')?.viewJSON?()
      console.log "YUP...", @get('default-image')
      json['default-image'] = @get('default-image')?.viewJSON?()
      json

    parse: (data) ->
      if data['default-image-id']
        content = App.request("content:entity", data['store-id'], data['default-image-id'])
        data['default-image'] = content
        # trigger an event when related models are fetched
        xhrs = [content._fetch]
        $.when.apply($, xhrs).done(=> @trigger('related-fetched'))
      data

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
