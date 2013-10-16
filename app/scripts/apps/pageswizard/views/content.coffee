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
      "click #all-content": "allContent"
      "click #added-to-page": "addedToPage"

    addedToPage: (event) ->
      @trigger("display:added-to-page")

    allContent: (event) ->
      @trigger("display:all-content")

    triggers:
      "click .js-next": "save"

    regions:
      "contentList": ".content > .list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .content").addClass("active")

    onShow: (opts) ->

  Views
