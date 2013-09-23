define [
  "marionette",
  "../views",
  "stickit"
], (Marionette, Views) ->

  class Views.PageIndex extends Marionette.Layout

    template: "pages_index"

    serializeData: ->
      return {
        pages: @collection.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    initialize: (opts) ->
      @collection = @model

  Views