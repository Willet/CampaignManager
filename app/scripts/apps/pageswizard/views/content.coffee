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

    triggers:
      "click .js-next": "save"
      "click .generate": "generate"

    regions:
      "contentList": ".content > .list"

    initialize: (opts) ->

    onRender: (opts) ->
      @$(".steps .content").addClass("active")

    onShow: (opts) ->

  Views
