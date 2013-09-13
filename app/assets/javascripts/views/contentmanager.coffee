define [
  "marionette",
  "backboneprojections",
  "entities/content",
  "jquery",
  "select2"
], (Marionette, BackboneProjections, ContentEntities, $) ->

  ContentActions =

    undecideContent: (event) ->
      @model.undecided()
      event.stopPropagation()
      false

    approveContent: (event) ->
      @model.approve()
      event.stopPropagation()
      false

    rejectContent: (event) ->
      @model.reject()
      event.stopPropagation()
      false

    prioritizeContent: (event) ->
      alert("TODO: prioritize items")
      event.stopPropagation()
      false

  class ListItem extends Marionette.Layout

    template: "_content_grid_item"

    events:
      "click .item": "viewModal"
      "click a": "stopPropagation"

    regions:
      "editArea": ".edit-area"

    serializeData: -> @model.viewJSON()

    initialize: ->
      @model.on("change", (=> _.throttle(_.defer(=> @render))))

    onRender: ->
      @editArea.show(new EditArea(model: @model))

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      require("app").modal.show(new Show(model: @model))
      event.stopPropagation()
      false

  class GridItem extends Marionette.Layout

    template: "_content_grid_item"

    regions:
      "editArea": ".edit-area"

    events:
      "click .overlay": "selectItem"
      "click .js-view": "viewModal"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "click .js-undecided": "undecideContent"
      "click .js-prioritize": "prioritizeContent"
      "click .js-select": "toggleSelected"
      "click a": "stopPropagation"

    initialize: ->
      _.extend(@, ContentActions)
      @model.on("change", => @render())

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))

    serializeData: -> @model.viewJSON()

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      require("app").modal.show(new QuickView(model: @model))
      event.stopPropagation()
      false

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))

    stopPropagation: (event) ->
      event.stopPropagation()
      false

    onRender: ->
      @editArea.show(new EditArea(model: @model))

    class QuickView extends Marionette.ItemView

      template: "_content_quick_view"

      serializeData: -> @model.viewJSON()

  class EditArea extends Marionette.Layout

    template: "_content_edit_item"

    serializeData: -> @model.viewJSON()

    events:
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "select2-blur .js-tagged-products": "productsChanged"
      "select2-blur .js-tagged-pages": "pagesChanged"

    initialize: ->
      _.extend(@, ContentActions)

    productsChanged: (event) ->
      @trigger("change:tagged-products", @$(".js-tagged-products").select2("data"))

    pagesChanged: (event) ->
      @trigger("change:tagged-pages", @$(".js-tagged-pages").select2("data"))

    setupTaggedProducts: ->
      @$('.js-tagged-products').select2(
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
      false

    setupTaggedPages: ->
      # TODO: CACHE THIS
      $.ajax("#{require("app").apiRoot}/stores/#{@model.get("store-id")}/campaigns").success( (data) =>

        @$('.js-tagged-pages').select2(
          multiple: true
          allowClear: true
          placeholder: "Search for a page"
          tokenSeparators: [',']
          data:
            results: data['campaigns']
            text: (item) -> item['name']
          formatNoMatches: (term) ->
            "No pages match '#{term}'"
          formatResult: (campaign) ->
            "<span>#{campaign['name']}</span>"
          formatSelection: (campaign) ->
            "<span>#{campaign['name']} #{campaign['id']}</span>"
        )
      )

    onShow: ->
      @on("change:tagged-products", (data) -> console.log data)
      @setupTaggedProducts()
      @setupTaggedPages()

    onClose: ->
      @$('.js-tagged-products').select2('destroy')

  class ContentList extends Marionette.CollectionView

    getItemView: (item) ->
      GridItem

  class Index extends Marionette.Layout

    id: 'content-index'

    className: "grid-view"

    template: "content_index"

    regions:
      "itemRegion": "#items"
      "editArea": ".edit-area"

    events:
      "click .js-select-all": "selectAll"
      "click .js-unselect-all": "unselectAll"
      "click dd": "updateActive"
      "click .js-next-page": "nextPage"
      "change #sort-order": "updateSortOrder"
      "change #filter-page": "filterPage"
      "change #filter-content-type": "filterContentType"

    last_id: null

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
      $.when(
        @model.getNextPage()
      ).done(=>
        @trigger("nextpage")
      )
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
      @$el.removeClass("grid-view").removeClass("list-view").addClass("#{new_state}-view")
      @itemRegion.currentView.render()

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      @current_state = opts['inital_state']
      @contentListView = new ContentList(
        collection: @model
      )
      @editView = new EditArea(model: new ContentEntities.Model("store-id": -1))

    unselectAll: ->
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: false)))

    selectAll: ->
      # TODO: this is a hack
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: true)))

    onRender: (opts) ->
      @itemRegion.show(@contentListView)
      @editArea.show(@editView)
      #@$('#js-tag-search').tokenInput()

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class ViewModeSelect extends Marionette.ItemView

    template: "_view_mode_select"

    events:
      "click dd": "updateActive"

    initialize: (opts) ->
      @current_state = opts['inital_state']

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
      @trigger('new-state', @current_state)

  class Show extends Marionette.Layout

    template: "content_show"

    events:
      "click .js-save": "saveContent"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      _.extend(@, ContentActions)

    onRender: (opts) ->

    onShow: (opts) ->

    saveContent: (event) ->
      data = @$('form').serializeObject()
      @model.save(data)
      false

  return {
    Index: Index
    Show: Show
  }


