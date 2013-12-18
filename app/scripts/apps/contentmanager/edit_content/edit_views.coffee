define [
  'app',
  '../views',
  'jquery'
], (App, Views, $) ->
  # TODO the name is long but it follows the convention followed in some places
  # keep or change?
  class Views.EditContentView extends App.Views.Layout
    template: 'content/edit/index'

    regions:
      taggedProducts: '.tagged-products'
      addTaggedProducts: '.tag-products'

    serializeData: -> @model.viewJSON()

    onShow: ->
      # TODO move somewhere else
      storeId = App.routeModels.get('store').id

      $('.tag-products').select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{App.API_ROOT}/store/#{storeId}/product/live"
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
    onclose: ->
      $('.tag-products').select2('destroy')


  class Views.EditContentProducts extends App.Views.CompositeView
    template: 'content/edit/products'

  class Views.EditContentDisplay extends App.Views.ItemView
    template: 'content/edit/preview'

  Views
