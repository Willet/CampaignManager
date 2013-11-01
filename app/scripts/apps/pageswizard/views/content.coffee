define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateContent extends Marionette.Layout

    template: "page/content"

    regions:
      "contentList": ".content-list-region"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
      }

    triggers:
      "click .js-next": "save"

    events:
      "click #filter-suggested-content": "displaySuggestedContent"
      "click #filter-all-content": "displayAllContent"
      "click #filter-added-content": "displayAddedContent"

    displaySuggestedContent: (event) ->
      @trigger('display:suggested-content')
      # we need it to trigger into the page for visual reasons
      true

    displayAddedContent: (event) ->
      @trigger('display:added-content')
      # we need it to trigger into the page for visual reasons
      true

    displayAllContent: (event) ->
      @trigger('display:all-content')
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

    onShow: (opts) ->
      # TODO: remove dangling pointer to the view that is shown
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class Views.PageCreateContentList extends Marionette.CollectionView

    tagName: "ul"
    className: "content-list"
    template: false

    getItemView: (item) ->
      Views.PageCreateContentGridItem

  class Views.PageCreateContentGridItem extends Marionette.ItemView

    tagName: "li"
    className: "content-item"
    template: "page/content_item_grid"

    triggers:
      "click .js-content-prioritize": "prioritize_content"
      "click .js-content-add": "add_content"
      "click .js-content-remove": "remove_content"


  Views
