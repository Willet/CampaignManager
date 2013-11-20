define [
  'app',
  '../app',
  'entities'
], (App, ContentManager, Entities) ->

  ContentManager.List ?= {}

  class ContentManager.List.ContentIndexLayout extends App.Views.Layout

    template: 'content/index'

    regions:
      "list": "#list"
      "listControls": "#list-controls"
      "multiedit": ".edit-area"

    events:
      "click dd": "updateActive"
      "change #sort-order": "updateSortOrder"
      "change #filter-page": "filterPage"
      "change #filter-content-type": "filterContentType"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    triggers:
      "click .js-select-all": "content:select-all"
      "click .js-unselect-all": "content:unselect-all"

    initialize: (opts) ->
      @current_state = opts['initial_state']

    filterContentType: (event) ->
      @trigger("change:filter-content-type", @$(event.currentTarget).val())

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    updateSortOrder: (event) ->
      @trigger("change:sort-order", @$(event.currentTarget).val())

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    nextPage: ->
      @$('.loading').show()
      @trigger("fetch:next-page")
      false

    updateActive: (event) ->
      @switchActive(@extractState(event.currentTarget))

    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    currentlyActive: ->
      @$('.tabs dd.active').className.split(/\s+/)

    switchActive: (new_state) ->
      @$(".tabs .active").removeClass("active")
      @$(".tabs .js-tab-#{new_state}").addClass("active")
      @current_state = new_state
      @$('#list').removeClass("grid-view").removeClass("list-view").addClass("#{new_state}-view")

    onRender: (opts) ->

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)
      @$('.loading').hide()
      @on "fetch:next-page:complete", =>
        @$('.loading').hide()

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class ContentManager.List.ContentListControls extends App.Views.ItemView

    template: "content/list_controls"

    events:
      "click dd": "updateActive"

    initialize: (opts) ->
      @current_state = "grid"

    updateActive: (event) ->
      @switchActive(@extractState(event.currentTarget))

    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    currentlyActive: ->
      @$('.tabs dd.active').className.split(/\s+/)

    switchActive: (new_state) ->
      @$(".tabs .active").removeClass("active")
      @$(".tabs .js-tab-#{new_state}").addClass("active")
      @current_state = new_state
      @trigger('change:state', @current_state)

  class ContentManager.List.ContentQuickView extends App.Views.ItemView

    template: "content/quick_view"

    serializeData: -> @model.viewJSON()

  ContentManager.List.TaggedPagesInput = App.Views.ItemView.extend

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

  ContentManager.List.TaggedProductInput = App.Views.ItemView.extend

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

  class ContentManager.List.ContentEditArea extends App.Views.Layout

    template: "content/edit_item"

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    regions:
      "taggedProducts": ".js-tagged-products"
      "taggedPages": ".js-tagged-pages"

    triggers:
      "click .js-approve": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-undecided": "content:undecided"
      "click .js-b2b": "content:b2b" # DIRTY HACK
      "click .js-nob2b": "content:nob2b" # DIRTY HACK

    initialize: (options) ->
      @actions = options['actions']
      @multiEdit = options['multiEdit']

    onShow: ->

    onRender: ->
      taggedProductInputConfig = model: @model, store: @store
      taggedPagesInputConfig = model: @model, store: @store

      if @multiEdit
          taggedProductInputConfig['collection'] = @model
          taggedProductInputConfig['store_id'] = @actions['store_id']
          delete taggedProductInputConfig['model']

          taggedPagesInputConfig['collection'] = @model
          taggedPagesInputConfig['store_id'] = @actions['store_id']
          delete taggedPagesInputConfig['model']


      @taggedProducts.show(new Views.TaggedProductInput(taggedProductInputConfig))
      @taggedPages.show(new Views.TaggedPagesInput(taggedPagesInputConfig))
      @relayEvents(@taggedProducts.currentView, 'tagged-products')
      @relayEvents(@taggedPages.currentView, 'tagged-pages')

    onClose: ->

  class ContentManager.List.ContentList extends App.Views.CollectionView

    template: false

    initialize: (options) ->
      @itemViewOptions = { actions: options.actions }

    getItemView: (item) ->
      Views.ContentGridItem

  class ContentManager.List.ContentGridItem extends App.Views.Layout

    template: "content/grid_item"

    regions:
      "editArea": ".edit-area"

    triggers:
      "click .js-select": "content:select-toggle"
      "click .overlay": "content:select-toggle"
      "click .js-approve": "content:approve"
      "click .js-approve-for-page": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-reject-for-page": "content:reject"
      "click .js-undecided": "content:undecided"
      "click .js-prioritize": "content:prioritize"
      "click .js-prioritize-for-page": "content:prioritize"
      "click .js-remove-from-page": "content:reject"
      "click .js-view": "content:preview"

    bindings:
      '.js-selected':
        attributes: [
          name: 'checked'
          observe: 'selected'
          onGet: (observed) ->
            if observed then true else false
        ]
      '.item':
        attributes: [
          name: 'class'
          observe: 'selected'
          onGet: (observed) ->
            if observed then "selected" else ""
        ]
      '.status':
        attributes: [
          {
            name: 'class'
            observe: ['active', 'approved']
            onGet: (observed) ->
              active = observed[0]
              approved = observed[1]
              if active && approved
                "approved"
              else if active && !approved
                "undecided"
              else
                "rejected"
          }
        ]

    initialize: (options) ->
      @actions = { actions: options.actions }
      @model.on('nested-change', => @render())
      @model.on('sync:tagged-products', => @render())

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    stopPropagation: (event) ->
      event.stopPropagation()
      false

    onRender: ->
      @editArea.show(new Views.ContentEditArea(model: @model, actions: @actions))
      @relayEvents(@editArea.currentView, 'edit')
      @stickit()

    onShow: ->

  ContentManager.List