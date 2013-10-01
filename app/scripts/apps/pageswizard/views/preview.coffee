define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PagePreview extends Marionette.Layout

    template: "pages_view"

  Views