define ["marionette"], ->
  class Main extends Marionette.ItemView

    template: "main_index"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  class Nav extends Marionette.ItemView

    template: "nav"

    initialize: (opts) ->

    serializeData: ->
      if @model
        {
          store: @model.toJSON?()
        }
      else
        {}

    onRender: (opts) ->

    onShow: (opts) ->

  return {
    Main: Main
    Nav: Nav
  }
