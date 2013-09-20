define [
  "marionette",
  "jquery",
  "entities",
  "select2"
], (Marionette, $, Entities) ->

  Views = Views || {}

  class Views.ContentIndexLayout extends Marionette.Layout

    template: 'content_index'

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
      @current_state = opts['inital_state']

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

    onClose: ->
      $(window).off("scroll", @scrollFunction)


  class Views.ContentList extends Marionette.CollectionView

    template: false

    initialize: (options) ->
      @itemViewOptions = { actions: options.actions }

    getItemView: (item) ->
      Views.ContentGridItem

  class Views.ContentGridItem extends Marionette.Layout

    template: "_content_grid_item"

    regions:
      "editArea": ".edit-area"

    triggers:
      "click .js-select": "content:select-toggle"
      "click .overlay": "content:select-toggle"
      "click .js-approve": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-undecided": "content:undecided"
      "click .js-prioritize": "content:prioritize" # NOT USED
      "click .js-view": "content:preview"

    initialize: (options) ->
      @model.on("change", => @render())
      @actions = { actions: options.actions }

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    stopPropagation: (event) ->
      event.stopPropagation()
      false

    onRender: ->
      @editArea.show(new Views.ContentEditArea(model: @model, actions: @actions))
      @relayEvents(@editArea.currentView, 'edit')

    onShow: ->

  class Views.ContentQuickView extends Marionette.ItemView

    template: "_content_quick_view"

    serializeData: -> @model.viewJSON()

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

  class Views.ContentEditArea extends Marionette.Layout

    template: "_content_edit_item"

    serializeData: -> _.extend(@model.viewJSON(), @actions)

    regions:
      "taggedProducts": ".js-tagged-products"
      "taggedPages": ".js-tagged-pages"

    triggers:
      "click .js-approve": "content:approve"
      "click .js-reject": "content:reject"
      "click .js-undecided": "content:undecided"

    initialize: (options) ->
      @actions = options['actions']

    onShow: ->
      @taggedProducts.show(new Views.TaggedProductInput(model: @model))
      @taggedPages.show(new Views.TaggedPagesInput(model: @model))
      @relayEvents(@taggedProducts.currentView, 'tagged-products')
      @relayEvents(@taggedPages.currentView, 'tagged-pages')

    onRender: ->

    onClose: ->

  class Views.ContentListControls extends Marionette.ItemView

    template: "_content_list_controls"

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

  Views
