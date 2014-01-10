define [
  'app',
  '../app',
  '../views',
  'entities'
], (App, ContentManager, Views, Entities) ->

  class Views.ListLayout extends App.Views.Layout

    template: 'content/index'

    regions:
      "list": ".content-list-region"
      "listControls": "#list-controls"
      "multiedit": ".edit-area"

    events:
      "click dd": "updateActive"
      "change #js-filter-page": "filterPage"
      "click .js-filter-content-status": "filterContentStatus"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    triggers:
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"
      "click .js-select-all": "content:select-all"
      "click .js-unselect-all": "content:unselect-all"

    initialize: (opts) ->
      @current_state = opts['initial_state']
      @status = ''

    # event triggered when all/needs review/approved/rejected tabs are clicked
    filterContentStatus: (event) ->
      @status = @$(event.currentTarget).val()

      # 'all' cannot filter by type, source, and tags
      @$('.content-filter-actions').prop('disabled', not @status)

      @trigger("change:filter-content-status", @status)

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

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

      # 'all' cannot filter by type, source, and tags
      @$('.content-filter-actions').prop('disabled', true)

      @on "fetch:next-page:complete", =>
        @$('.loading').hide()

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class Views.ContentListControls extends App.Views.ItemView

    template: "content/filter_controls"

    events:
      "click dd": "updateActive"
      "keyup #js-filter-content-tags": "changeFilter"
      "change #js-filter-content-type": "changeFilter"
      "change #js-filter-content-source": "changeFilter"
      "change #js-filter-sort-order": "changeFilter"

    initialize: (opts) ->
      @current_state = "grid"

    changeFilter: () ->
      filter = {}
      filter['type'] = @$('#js-filter-content-type').val()
      filter['source'] = @$('#js-filter-content-source').val()
      filter['tags'] = @$('#js-filter-content-tags').val()

      # differentiate two kinds of UI "sort by": import/post dates,
      # only one of which can be used to sort the list at any given time
      sortKey = @$('#js-filter-sort-order').val()
      sortDirection = @$('#js-filter-sort-order option:selected').data('direction')
      @$('#js-filter-sort-order option').each () ->
          key = $(this).val()
          filter[key] = ''
      filter[sortKey] = sortDirection

      _.each(_.keys(filter), (key) -> delete filter[key] if filter[key] == null || !/\S/.test(filter[key]))
      @trigger("change:filter", filter)

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

  class Views.ContentPreview extends App.Views.ItemView

    template: "content/item_preview"

    serializeData: -> @model.viewJSON()

  Views.TaggedPagesInput = App.Views.ItemView.extend

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

  Views.TaggedProductInput = App.Views.ItemView.extend

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

  class Views.ContentList extends App.Views.CollectionView

    template: false
    tagName: "ul"
    className: "content-list"

  class Views.ContentListItem extends App.Views.ItemView

    tagName: "li"
    className: "content-item list-view"
    template: "content/item_list"

    triggers:
      "click .js-content-select": "content:select-toggle"
      "click .js-content-approve": "approve_content"
      "click .js-content-reject": "reject_content"
      "click .js-content-undecided": "undecide_content"
      "click .js-content-preview": "preview_content"
      "click .js-content-edit": "edit_content"

  class Views.ContentGridItem extends App.Views.ItemView

    tagName: "li"
    className: "content-item grid-view"
    template: "content/item_grid"

    triggers:
      "click .js-content-select": "content:select-toggle"
      "click .js-content-approve": "approve_content"
      "click .js-content-reject": "reject_content"
      "click .js-content-undecided": "undecide_content"
      "click .js-content-preview": "preview_content"
      "click .js-content-edit": "edit_content"
      "click .js-content-approve-edit": "approve_content edit_content"

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

    initialize: ->
      @model.on('change:status', => @render())

    onRender: ->
      @stickit()

  Views
