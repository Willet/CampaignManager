define ["marionette", "models/pages"], (Marionette, Pages) ->

  class Index extends Marionette.Layout

    template: "pages_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.Layout

    template: "pages_show"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  # declare exports
  return {
    Index: Index
    Show: Show
  }


