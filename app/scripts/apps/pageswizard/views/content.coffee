define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateContent extends Marionette.Layout

    template: "page/content"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    events:
      "click #needs-review": "displayNeedsReview"
      "click #added-to-page": "displayAddedToPage"

    displayNeedsReview: (event) ->
      @trigger('display:needs-review')
      true

    displayAddedToPage: (event) ->
      @trigger('display:added-to-page')
      true

    triggers:
      "click .js-next": "save"

    regions:
      "contentList": ".content > .list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .content").addClass("active")

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    nextPage: ->
      @$('.loading').show()
      @trigger("fetch:next-page")
      false

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  Views
