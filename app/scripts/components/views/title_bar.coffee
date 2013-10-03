define [
  "marionette"
], (Marionette) ->

  class TitleBar extends Marionette.ItemView

    template: "shared/title_bar"

    initialize: (opts) ->
      @listenTo(@model, 'sync', @render())

  return TitleBar