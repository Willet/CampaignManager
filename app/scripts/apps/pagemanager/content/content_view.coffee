define [
  'app',
  '../views',
  'backbone.stickit'
], (App, Views) ->

  class Views.PageCreateContent extends App.Views.SortableLayout

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
      "change #js-filter-type": "change:filter"
      "change #js-filter-content-source": "change:filter"
      "blur #js-filter-tags": "change:filter"
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"
      "click .js-select-all": "select-all"
      "click .js-select-none": "select-none"
      "click .js-add-selected": "add-selected"
      "click .js-remove-selected": "remove-selected"

    events:
      "click #filter-suggested-content": "displaySuggestedContent"
      "click #filter-all-content": "displayAllContent"
      "click #filter-added-content": "displayAddedContent"
      "click #filter-import-content": "displayImportContent"

    resetFilters: () ->
      @$('#js-filter-sort-order option[value="order"][data-direction="descending"]').prop('selected', 'selected')
      @$('#js-filter-type').val('')
      @$('#js-filter-content-source').val('')
      @$('#js-filter-tags').val('')

    extractFilter: () ->
      filter = super(status: 'approved')  # defaults plus {'status'}

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


    initialize: (options) ->
      @contentList.on("show", ((view) => @relayEvents(view, 'content_list')))
      @contentList.on("close", ((view) => @stopRelayEvents(view)))

    nextPage: ->
      @trigger("fetch:next-page")
      false

    onRender: ->

    onShow: (opts) ->
      # TODO: remove dangling pointer to the view that is shown
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)
      @displaySuggestedContent()

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    onClose: ->
      $(window).off("scroll", @scrollFunction)


  class Views.PageCreateContentPreview extends App.Views.ItemView
    template: 'page/content/item_preview'


  class Views.PageCreateContentList extends App.Views.CollectionView
    className: "content-list"


  class Views.PageCreateContentGridItem extends App.Views.ListItemView
    className: "content-item grid-view"
    template: "page/content/item_grid"

    triggers:
      "click .js-content-prioritize": "prioritize_content"
      "click .js-content-deprioritize": "deprioritize_content"
      "click .js-content-add": "add_content"
      "click .js-content-remove": "remove_content"
      "click .js-content-preview": "preview_content"


  class Views.PageCreateContentListItem extends App.Views.ListItemView
    className: "content-item list-view"
    template: "page/content/item_list"

    triggers:
      "click .js-content-prioritize": "prioritize_content"
      "click .js-content-add": "add_content"
      "click .js-content-remove": "remove_content"
      "click .js-content-preview": "preview_content"


  Views
