define [
  "marionette",
  "entities",
  "../views",
  "jquery",
  "select2"
], (Marionette, Entities, Views, $) ->

  Views.TaggedPagesInput = Marionette.ItemView.extend

    template: false

    initialize: (options) ->
      @store = options.store

    onShow: ->
      self = @
      @$el.parent().select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a page"
        tokenSeparators: [',']
        query: (query) ->
          $.ajax "#{App.API_ROOT}/store/#{self.model.get("store-id")}/page",
            success: (data) ->
              query.callback(data)
        data:
          results: [] # TODO: needs page data
          text: (item) -> item['name']
        formatNoMatches: (term) ->
          "No pages match '#{term}'"
        formatResult: (page) ->
          "<span>#{page['name']}</span>"
        formatSelection: (page) ->
          "<span>#{page['name']}</span>"
      ).on "change", (e) ->
        # TODO: I have no idea where the endpoint is
        # added:e.added, removed:e.removed
      false

    onClose: ->
      @$el.parent().select2("destroy")

  Views.TaggedProductInput = Marionette.ItemView.extend

    template: false

    initialize: (options) ->
      @store = options['store']
      @storeId = options['store_id']

    onShow: ->
      # BUG: If this is a part of a multi-edit, there will be a problem with
      # accessing store / page
      storeId = @store?.get('id') or @storeId
      @$el.parent().select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{App.API_ROOT}/store/#{@storeId}/product/live"
          dataType: 'json'
          cache: true
          data: (term, page) ->
            return {
              "search-name": term
            }
          results: (data, page) ->
            return {
              results: data['results']
            }
        formatResult: (product) ->
          "<span>#{product['name']}</span>"
        formatSelection: (product) ->
          "<span>#{product['name']}</span>"
      )
      if @model?.get("tagged-products")
        @$el.parent().select2('data', @model.get("tagged-products").toJSON())
      @$el.parent().on "change", (event, element) =>
        if event.added
          product = new Entities.Product(event.added)
          if @model
            @model.get('tagged-products').add(product)
            @trigger('add', model)
          else
            @collection.collect((m) =>
              m.get('tagged-products').add(product)
              m.set('selected', false)
            )
        if event.removed
          if @model
            product = @model.get('tagged-products').get(event.removed.id)
            @model.get('tagged-products').remove(product)
            @trigger('remove', product)
          else
            @collection.collect((m) =>
              product = m.get('tagged-products').get(event.removed.id)
              m.get('tagged-products').remove(product)
              m.set('selected', false)
            )
      false

    addProduct: (product) ->
      products = @$el.parent().select2("data")
      products.push(product.toJSON())
      @$el.parent().select2("data", products)

    removeProduct: (product_id) ->
      products = @$el.parent().select2("data")
      for product, i in products
        if product['id'] is product_id
          delete product[i]
          break
      @$el.parent().select2("data", products)

    onClose: ->
      @$el.parent().select2("destroy")

  Views
