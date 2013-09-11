define [
  "marionette",
  "backboneprojections",
  "models/content",
  "jquery",
  "select2"
], (Marionette, BackboneProjections, Content, $) ->

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
      "click .item > *": "stopPropagation"

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

    stopPropagation: (event) ->
      event.stopPropagation()

  class GridItem extends Marionette.Layout
    _.extend(@, ContentActions)

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

    onRender: ->
      @editArea.show(new EditArea(model: @model))

    class QuickView extends Marionette.ItemView

      template: "_content_quick_view"

      serializeData: -> @model.viewJSON()

  class EditArea extends Marionette.Layout
    _.extend(@, ContentActions)

    template: "_content_edit_item"

    serializeData: -> @model.viewJSON()

    events:
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "select2-blur .js-tagged-products": "productsChanged"
      "select2-blur .js-tagged-pages": "pagesChanged"

    initialize: ->

    productsChanged: (event) ->
      @trigger("change:tagged-products", @$(".js-tagged-products").select2("data"))

    pagesChanged: (event) ->
      @trigger("change:tagged-pages", @$(".js-tagged-pages").select2("data"))

    onShow: ->
      @on("change:tagged-products", (data) -> console.log data)
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
        collection: new BackboneProjections.Sorted(@model, comparator: (m) -> [m.get('selected'), m.get('id')])
      )
      @editView = new EditArea(model: new Content.Model("store-id": -1))

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

    onClose: ->

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
    _.extend(@, ContentActions)

    template: "content_show"

    events:
      "click .js-save": "saveContent"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->

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


