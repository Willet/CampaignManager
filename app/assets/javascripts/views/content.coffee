define ["marionette", "models/content"], (Marionette, Content) ->

  class Index extends Marionette.Layout

    template: "content_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.Layout

    template: "content_show"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  # declare exports
  return {
    Index: Index
    Show: Show
  }


