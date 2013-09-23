define [
  "marionette",
  "entities",
  "../views",
  "jquery",
  "select2"
], (Marionette, Entities, Views, $) ->

  class Views.TaggedPagesInput extends Marionette.ItemView

    template: false

    onShow: ->
      @$el.parent().select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a page"
        tokenSeparators: [',']
        data:
          results: [] # TODO: needs page data
          text: (item) -> item['name']
        formatNoMatches: (term) ->
          "No pages match '#{term}'"
        formatResult: (campaign) ->
          "<span>#{campaign['name']}</span>"
        formatSelection: (campaign) ->
          "<span>#{campaign['name']} #{campaign['id']}</span>"
      )
      false

    onClose: ->
      @$el.parent().select2("destroy")

  class Views.TaggedProductInput extends Marionette.ItemView

    template: false

    onShow: ->
      @$el.parent().select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{require("app").apiRoot}/stores/#{@model.get("store-id")}/products"
          dataType: 'json'
          cache: true
          data: (term, page) ->
            return {
              "name-prefix": term
            }
          results: (data, page) ->
            return {
              results: data['products']
            }
        formatResult: (product) ->
          "<span>#{product['name']}</span>"
        formatSelection: (product) ->
          "<span>#{product['name']} #{product['id']}</span>"
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

    addProduct: (product) =>
      products = $('div#selection-edit .js-tagged-products').select2("data")
      products.push(product.toJSON())
      $('div#selection-edit .js-tagged-products').select2("data", products)

    removeProduct: (product_id) =>
      products = @$('div#selection-edit .js-tagged-products').select2("data")
      for product, i in products
        if product['id'] is product_id
          delete product[i]
          break
      @$('div#selection-edit .js-tagged-products').select2("data", products)

    onClose: ->
      @$el.parent().select2("destroy")

  Views