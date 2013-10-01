define [
  "marionette",
  "entities",
  "../views",
], (Marionette, Entities, Views) ->

  class Views.ContentQuickView extends Marionette.ItemView

    template: "_content_quick_view"

    serializeData: -> @model.viewJSON()

  Views