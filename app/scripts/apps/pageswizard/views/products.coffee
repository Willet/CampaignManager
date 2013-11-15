define [
  "marionette",
  "../views",
  "backbone.stickit",
  "select2"
], (Marionette, Views) ->

  Views.PageCreateProducts = Marionette.Layout.extend

    template: "page/product/main"

    triggers:
      "click .js-next": "save"
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"

    events:
      "click #filter-import-product": "displayImportProduct"
      "click #filter-all-product": "displayAllProduct"
      "click #filter-added-product": "displayAddedProduct"

    extractFilter: () ->
      filter = {}
      filter['tags'] = @$('#js-filter-product-tags').val()
      filter['order'] = @$('#js-filter-sort-order').val()
      _.each(_.keys(filter), (key) -> delete filter[key] if filter[key] == null || !/\S/.test(filter[key]))
      return filter;

    displayImportProduct: (event) ->
      @trigger('display:import-product')
      @$('.import-product').show()
      @$('.product-options').hide()
      # we need it to trigger into the page for visual reasons
      true

    displayAddedProduct: (event) ->
      @trigger('display:added-product')
      @$('.import-product').hide()
      @$('.product-options').show()
      # we need it to trigger into the page for visual reasons
      true

    displayAllProduct: (event) ->
      @trigger('display:all-product')
      @$('.import-product').hide()
      @$('.product-options').show()
      # we need it to trigger into the page for visual reasons
      true

    resetError: (event) ->
      $(event.currentTarget).removeClass("error")

    validUrl: (url) ->
      # TODO: move this to the scrape model ?
      urlPattern = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
      url && url != "" && urlPattern.test(url)

    addAllProducts: ->
      event.stopPropagation()
      _.defer(=> @productList.currentView.children.each((child) -> child.addToPageAlso()))
      false

    addUrl: (event) ->
      if @validUrl(@$('#url').val())
        @trigger "new:scrape", @$('#url').val()
        @$('#url').val("")
      else
        @$('#url').addClass("error")
        # figure out what to do
      event.stopPropagation()
      false

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    regions:
      "productList": ".product-list-region"
      "productAddedBySearch": ".product-added-search.success"

    initialize: (opts) ->
      @productList.on("show", ((view) => @relayEvents(view, 'product_list')))
      @productList.on("close", ((view) => @stopRelayEvents(view)))

    onRender: (opts) ->
      @$(".steps .products").addClass("active")
      @$(@productAddedBySearch.el).hide()
      @displayImportProduct()

    onShow: (opts) ->
      # TODO: unhard-code this...
      @$('#search-product').select2(
        multiple: false
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          # TODO: un-hardcode
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
        @$(@productAddedBySearch.el).fadeIn(200).delay(1500).fadeOut(400)
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
    className: "product-list"
    tagName: "ul"

    initialize: (options) ->
      @itemViewOptions = { added: options['added'] }


  class Views.PageCreateProductPreview extends Marionette.ItemView

    template: 'page/product/item_preview'

    serializeData: -> @model.viewJSON()

  class Views.PageProductListItem extends Marionette.Layout

    # TODO: implement a sane version of "added"
    #       how do we figure out if a product is in a page...
    template: "page/product/item_list"
    className: "product-item list-view"
    tagName: "li"

    serializeData: -> @model.viewJSON()

  class Views.PageProductGridItem extends Marionette.Layout

    # TODO: implement a sane version of "added"
    #       how do we figure out if a product is in a page...
    template: "page/product/item_grid"
    className: "product-item grid-view"
    tagName: "li"

    serializeData: -> @model.viewJSON()

    triggers:
      "click .js-product-preview": "preview_product"
      "click .js-add-to-page": "add"
      "click .js-remove-from-page": "remove"

    events:
      "click": "selectItem"

    initialize: (options) ->
      throttled_render = _.throttle((=> @render()), 500, leading: false)
      @model.on('nested-change', throttled_render)

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))
      if @model.get('selected')
        @$el.addClass('selected')
      else
        @$el.removeClass('selected')


  Views
