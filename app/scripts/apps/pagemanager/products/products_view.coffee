define [
  'app'
  'exports',
  'backbone.stickit',
  'select2'
], (App, Views) ->

  class Views.PageCreateProducts extends App.Views.Layout

    template: "page/product/main"

    regions:
      productList: ".product-list-region"
      importRegion: ".import-product-region"

    triggers:
      "click .js-next": "save"
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"
      "click .js-select-all": "select-all"

    events:
      "click #filter-import-product": "displayImportProduct"
      "click #filter-all-product": "displayAllProduct"
      "click #filter-added-product": "displayAddedProduct"

    initialize: (opts) ->
      @productList.on("show", ((view) => @relayEvents(view, 'product_list')))
      @productList.on("close", ((view) => @stopRelayEvents(view)))

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

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    onRender: (opts) ->
      @importRegion.show new Views.ProductScrapersView()
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
        App.request("page:add_product", page, product)
        @trigger "added-product", product
        @$('#search-product').select2('val', null)
        @$(@productAddedBySearch.el).fadeIn(200).delay(1500).fadeOut(400)
      false

    onClose: ->
      @$('#search-product').select2("destroy")

  class Views.PageScrapeItem extends App.Views.ItemView

    template: "page/scrape_item"

    triggers:
      "click .remove": "remove"

    serializeData: ->
      @model.viewJSON()

  class Views.PageScrapeList extends App.Views.CollectionView

    itemView: Views.PageScrapeItem

  class Views.PageProductList extends App.Views.CollectionView

    template: false
    className: "product-list"
    tagName: "ul"

    initialize: (options) ->
      @allSelected = false

    itemViewOptions: -> { selected: @allSelected }

  class Views.PageCreateProductPreview extends App.Views.ItemView

    template: 'page/product/item_preview'

    serializeData: -> @model.viewJSON()

  pageProductModelSerialization = ->
      isAdded = @model.get('tile-configs').find((m) -> (m.get('template') == 'image'))
      page_status = if isAdded then 'added' else null
      return _.extend(@model.viewJSON(),
        {
          'page-status': @model.get('page-status') || page_status
        })

  class Views.PageProductListItem extends App.Views.Layout

    template: "page/product/item_list"
    className: "product-item list-view"
    tagName: "li"

    triggers:
      "click .js-product-prioritize": "prioritize_product"
      "click .js-product-deprioritize": "deprioritize_product"
      "click .js-product-add": "add_product"
      "click .js-product-remove": "remove_product"
      "click .js-product-preview": "preview_product"

    serializeData: pageProductModelSerialization

  class Views.PageProductGridItem extends App.Views.Layout

    template: "page/product/item_grid"
    className: "product-item grid-view"
    tagName: "li"

    triggers:
      "click .js-product-prioritize": "prioritize_product"
      "click .js-product-deprioritize": "deprioritize_product"
      "click .js-product-add": "add_product"
      "click .js-product-remove": "remove_product"
      "click .js-product-preview": "preview_product"

    events:
      "click": "selectItem"

    initialize: (options) ->
      throttled_render = _.throttle((=> @render()), 500, leading: false)
      @model.on('nested-change', throttled_render)

    serializeData: pageProductModelSerialization

    onRender: ->
      @updateDOM()
      @$el.attr('data-id', @model.get('id'))

    updateDOM: () ->
      if @model.get('selected')
        @$el.addClass('selected')
      else
        @$el.removeClass('selected')

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))
      @updateDOM()

  class Views.ProductScrapersView extends App.Views.Layout

    template: 'page/product/import'

    regions:
      addRegion: '.import-add-region'
      listRegion: '.import-list-region'

    onRender: ->
      @addRegion.show(new Views.ProductScrapeAddView())
      @listRegion.show(new Views.ProductScrapeList(collection: @options.collection))

  class Views.ProductScrapeAddView extends App.Views.ItemView

    template: 'page/product/import_add'

    resetError: (event) ->
      $(event.currentTarget).removeClass("error")

    addUrl: (event) ->
      if @validUrl(@$('#url').val())
        @trigger "new:scrape", @$('#url').val()
        @$('#url').val("")
      else
        @$('#url').addClass("error")
        # figure out what to do
      event.stopPropagation()
      false

    validUrl: (url) ->
      # TODO: move this to the scrape model ?
      urlPattern = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
      url && url != "" && urlPattern.test(url)

  class Views.ProductScrapeList extends App.Views.CollectionView

    template: false
    className: 'import-list'
    tagName: 'ul'

  class Views.ProductScrapeItem extends App.Views.ItemView

    template: 'page/product/import_item'
    className: 'import-item'
    tagName: 'li'

  Views
