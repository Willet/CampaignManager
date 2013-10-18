define [
  "marionette",
  "../views",
  "backbone.stickit",
  "select2"
], (Marionette, Views) ->

  class Views.PageCreateProducts extends Marionette.Layout

    template: "page/products"

    events:
      "click #add-url": "addUrl"
      "click #add-product": "addProduct"
      "keydown #url": "resetError"
      "click #needs-review": "displayNeedsReview"
      "click #added-to-page": "displayAddedToPage"

    displayNeedsReview: (event) ->
      @trigger('display:needs-review')
      true

    displayAddedToPage: (event) ->
      @trigger('display:added-to-page')
      true

    triggers:
      "click .js-next": "save"

    resetError: (event) ->
      $(event.currentTarget).removeClass("error")

    validUrl: (url) ->
      # TODO: move this to the scrape model ?
      urlPattern = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
      url && url != "" && urlPattern.test(url)

    addUrl: (event) ->
      if @validUrl(@$('#url').val())
        @trigger "new:scrape", @$('#url').val()
        @$('#url').val("")
      else
        @$('#url').addClass("error")
        # figure out what to do

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    regions:
      "scrapeList": "#scrape-list"
      "productList": "#product-list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .products").addClass("active")

    onShow: (opts) ->
      # TODO: unhard-code this...
      @$('#search-product').select2(
        multiple: false
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{App.API_ROOT}/store/38/product"
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
      @$('#search-product').on "change", (event, element) =>
        # TODO: move this out of the VIEW
        App.request("add_product:page:entity", {
            store_id: @model.get('store-id')
            page_id: @model.get('id')
            product_id: event.added.id
          }
        )
        @trigger "added-product", event.added
        @$('#search-product').select2('val', null)
      false

    onClose: ->
      @$('#search-product').select2("destroy")

  class Views.PageScrapeItem extends Marionette.ItemView

    template: "page/scrape_item"

    triggers:
      "click .remove": "remove"

    serializeData: ->
      @model.viewJSON()

  class Views.PageScrapeList extends Marionette.CollectionView

    itemView: Views.PageScrapeItem

  class Views.PageProductList extends Marionette.CollectionView

    template: false

    initialize: (options) ->

    getItemView: (item) ->
      Views.PageProductGridItem

  class Views.PageProductGridItem extends Marionette.Layout

    template: "page/product_item"

  Views
