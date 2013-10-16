define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  Views.PagePreview = Marionette.Layout.extend

    template: "page/view"

  Views
