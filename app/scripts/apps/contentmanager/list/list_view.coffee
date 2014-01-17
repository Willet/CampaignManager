define ['app', '../app', '../views', 'entities'
], (App, ContentManager, Views, Entities) ->

  class Views.ListLayout extends App.Views.SortableLayout

    template: 'content/index'

    regions:
      "list": ".content-list-region"
      "listControls": "#list-controls"
      "multiedit": ".edit-area"

    triggers:
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"
      "click .js-select-all": "content:select-all"
      "click .js-unselect-all": "content:unselect-all"

      "keyup #js-filter-tags": "change:filter"
      "change #js-filter-type": "change:filter"
      "change #js-filter-content-source": "change:filter"
      "change #js-filter-sort-order": "change:filter"

    events:
      "change #js-filter-page": "filterPage"
      "click .js-filter-content-status": "filterContentStatus"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    initialize: (opts) ->
      @current_state = opts['initial_state']
      @status = ''

    # event triggered when all/needs review/approved/rejected tabs are clicked
    filterContentStatus: (event) ->
      @status = @$(event.currentTarget).val()

      # 'all' cannot filter by type, source, and tags
      @$('.content-filter-actions').prop('disabled', not @status)

      @trigger("change:filter-content-status", @status)

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    onRender: (opts) ->

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)
      @$('.loading').hide()

      # 'all' cannot filter by type, source, and tags
      @$('.content-filter-actions').prop('disabled', true)

      super()

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class Views.ContentListControls extends App.Views.ItemView

    template: "content/filter_controls"

    initialize: (opts) ->
      @current_state = "grid"
      super(opts)


  class Views.ContentPreview extends App.Views.ItemView
    template: "content/item_preview"


  class Views.TaggedPagesInput extends App.Views.ItemView
    initialize: (options) ->
      @store = options.store
      super(opts)

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


  # TODO: grep test failed
  class Views.TaggedProductInput extends App.Views.ItemView
    initialize: (options) ->
      @store = options['store']
      @storeId = options['store_id']
      super(opts)

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


  class Views.ContentList extends App.Views.CollectionView
    className: "content-list"


  # superclass for handling events; use subclasses below
  class Views.ContentItemView extends App.Views.SelectableListItemView
    triggers:
      "click .js-content-approve": "approve_content"
      "click .js-content-reject": "reject_content"
      "click .js-content-undecided": "undecide_content"
      "click .js-content-preview": "preview_content"
      "click .js-content-edit": "edit_content"
      "click .js-content-approve-edit": "approve_content edit_content"

    initialize: ->
      @model.on('change:status', => @render())
      super()


  # Grid item view (mirror of list item view)
  class Views.ContentListItem extends Views.ContentItemView
    className: "content-item list-view"
    template: "content/item_list"


  # Grid item view (mirror of list item view)
  class Views.ContentGridItem extends Views.ContentItemView
    className: "content-item grid-view"
    template: "content/item_grid"


  Views
