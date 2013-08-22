define ["marionette", "models/stores"], (Marionette, Content) ->

  class Index extends Marionette.Layout

    template: "stores_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.Layout

    template: "stores_show"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  # declare exports
  return {
    Index: Index
    Show: Show
  }


