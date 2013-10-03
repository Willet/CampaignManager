define [
  "marionette"
], (Marionette) ->

  class MainLayout extends Marionette.Layout

    template: "layouts/main"

    regions:
      nav: "nav"
      content: "#content"
      controls: "#page-controls"
      titlebar: "#title-bar"

  MainLayout