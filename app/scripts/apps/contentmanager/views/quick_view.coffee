define [
  "marionette",
  "entities",
  "../views",
], (Marionette, Entities, Views) ->

  class Views.ContentQuickView extends Marionette.ItemView

    template: "content/quick_view"

    serializeData: -> @model.viewJSON()

  Views
