define ["marionette"], (Marionette) ->
  class Index extends Marionette.ItemView

    template: "products_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Show extends Marionette.ItemView

    template: "products_show"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  {
    Index: Index
    Show: Show
  }
