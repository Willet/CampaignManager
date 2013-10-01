define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PagePreview extends Marionette.Layout

    template: "page/view"

  Views
