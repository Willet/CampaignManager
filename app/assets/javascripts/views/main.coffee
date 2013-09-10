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

  class Nav extends Marionette.ItemView

    template: "nav"

    initialize: (opts) ->
      @model.on("change", => @render())

    serializeData: ->
      json = {}
      json['store'] = @model.get('store').toJSON() if @model.get('store')
      json['page'] = @model.get('page')
      json

  class TitleBar extends Marionette.ItemView

    template: "title_bar"

    initialize: (opts) ->
      @model.on("change", => @render())

  class NotFound extends Marionette.ItemView

    template: "404"

  class Index extends Marionette.Layout

    template: "stores_index"

  return {
    Main: Main
    Nav: Nav
    TitleBar: TitleBar
    Loading: Loading
    NotFound: NotFound
    Index: Index
  }
