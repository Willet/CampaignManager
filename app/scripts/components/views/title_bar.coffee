define [
  "app"
  "marionette"
], (App, Marionette) ->

  class TitleBar extends Marionette.ItemView

    template: "shared/title_bar"

    events:
      "click #logout": "logout"

    initialize: (opts) ->
      @listenTo(@model, 'sync', @render())
      super(opts)

  return TitleBar
