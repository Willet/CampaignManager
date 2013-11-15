define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateContent extends Marionette.Layout

    template: "page/content/main"

    regions:
      "contentList": ".content-list-region"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
      }

    triggers:
      "click .js-next": "save"
      "change #js-filter-sort-order": "change:filter"
      "change #js-filter-content-type": "change:filter"
      "change #js-filter-content-source": "change:filter"
      "blur #js-filter-content-tags": "change:filter"
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"

    events:
      "click #filter-suggested-content": "displaySuggestedContent"
      "click #filter-all-content": "displayAllContent"
      "click #filter-added-content": "displayAddedContent"
      "click #filter-import-content": "displayImportContent"

    resetFilters: () ->
      @$('#js-filter-sort-order').val('descending')
      @$('#js-filter-content-type').val('')
      @$('#js-filter-content-source').val('')
      @$('#js-filter-content-tags').val('')

    extractFilter: () ->
      filter = {}
      filter['source'] = @$('#js-filter-content-source').val()
      filter['type'] = @$('#js-filter-content-type').val()
      filter['tags'] = @$('#js-filter-content-tags').val()
      filter['order'] = @$('#js-filter-sort-order').val()
      _.each(_.keys(filter), (key) -> delete filter[key] if filter[key] == null || !/\S/.test(filter[key]))
      return filter;

    displaySuggestedContent: (event) ->
      @trigger('display:suggested-content')
      @resetFilters()
      @$('.content-options').show()
      @$('.add-content').hide()
      # we need it to trigger into the page for visual reasons
      true

    displayAddedContent: (event) ->
      @trigger('display:added-content')
      @resetFilters()
      @$('.content-options').show()
      @$('.add-content').hide()
      # we need it to trigger into the page for visual reasons
      true

    displayAllContent: (event) ->
      @trigger('display:all-content')
      @resetFilters()
      @$('.content-options').show()
      @$('.add-content').hide()
      # we need it to trigger into the page for visual reasons
      true

    displayImportContent: (event) ->
      @trigger('display:import-content')
      @resetFilters()
      @$('.content-options').hide()
      @$('.add-content').show()
      # we need it to trigger into the page for visual reasons
      true

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    initialize: (options) ->
      @contentList.on("show", ((view) => @relayEvents(view, 'content_list')))
      @contentList.on("close", ((view) => @stopRelayEvents(view)))

    nextPage: ->
      @$('.loading').show()
      @trigger("fetch:next-page")
      false

    onRender: ->
      @displaySuggestedContent()

    onShow: (opts) ->
      # TODO: remove dangling pointer to the view that is shown
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class Views.PageCreateContentPreview extends Marionette.ItemView

    template: 'page/content/item_preview'

    serializeData: -> @model.viewJSON()

  class Views.PageCreateContentList extends Marionette.CollectionView

    tagName: "ul"
    className: "content-list"
    template: false


  class Views.PageCreateContentGridItem extends Marionette.ItemView

    tagName: "li"
    className: "content-item grid-view"
    template: "page/content/item_grid"

    triggers:
      "click .js-content-prioritize": "prioritize_content"
      "click .js-content-add": "add_content"
      "click .js-content-remove": "remove_content"
      "click .js-content-preview": "preview_content"

    events:
      "click": "selectItem"

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))
      if @model.get('selected')
        @$el.addClass('selected')
      else
        @$el.removeClass('selected')

    serializeData: -> @model.viewJSON()

  class Views.PageCreateContentListItem extends Marionette.ItemView

    tagName: "li"
    className: "content-item list-view"
    template: "page/content/item_list"

    serializeData: -> @model.viewJSON()

    triggers:
      "click .js-content-prioritize": "prioritize_content"
      "click .js-content-add": "add_content"
      "click .js-content-remove": "remove_content"
      "click .js-content-preview": "preview_content"

  Views
