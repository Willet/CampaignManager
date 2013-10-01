define [
  "marionette",
  "../views",
  "./header"
], (Marionette, Views) ->

  class Views.PageWizardLayout extends Marionette.Layout

    template: "page/wizard_layout"

    id: "page_wizard"

    regions:
      "content": ".content-region"
      "header": ".header-region"

    onShow: ->

  Views
