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

    onShow: ->
      @$el.parent().select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{App.API_ROOT}/store/#{@model.get("store-id")}/product"
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
      if @model.get("tagged-products")
        @$el.parent().select2('data', @model.get("tagged-products").toJSON())
      @$el.parent().on "change", (event, element) =>
        if event.added
          model = new Entities.Product(event.added)
          @model.get('tagged-products').add(model)
          @trigger('add', model)
        if event.removed
          model = @model.get('tagged-products').get(event.removed.id)
          @model.get('tagged-products').remove(model)
          @trigger('remove', model)
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
