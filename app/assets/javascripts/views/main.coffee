define ["marionette"], ->

  class Loading extends Marionette.ItemView

    template: "loading"

    initialize: (opts) ->
      defaults =
        initialized: true
        emptyMessage: "There are no items matching your criteria"
        loadingMessage: "Please wait. Loading..."
      @options = _.extend(defaults, opts)

    serializeData: ->
      {
        message: (if @options['initialized'] then @options['loadingMessage'] else @options['emptyMessage'])
      }

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

  class TitleBar extends Marionette.ItemView

    template: "title_bar"

    initialize: (opts) ->

    onRender: (opts) ->

    onShow: (opts) ->

  return {
    Main: Main
    Nav: Nav
    TitleBar: TitleBar
    Loading: Loading
  }
