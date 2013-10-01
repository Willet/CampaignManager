define [
  "marionette"
], (Marionette) ->

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

  class Nav extends Marionette.ItemView

    template: "shared/nav"

    initialize: (opts) ->
      @model.get('store')?.on("sync", => @render())

    serializeData: ->
      json = {}
      json['store'] = @model.get('store').toJSON() if @model.get('store')
      json['page'] = @model.get('page')
      json

  class TitleBar extends Marionette.ItemView

    template: "shared/title_bar"

    initialize: (opts) ->
      @listenTo(@model, 'sync', @render())

  class NotFound extends Marionette.ItemView

    template: "404"

  class Index extends Marionette.Layout

    template: "store/index"

  class Layout extends Marionette.Layout

    template: "layouts/main"

    regions:
      nav: "nav"
      content: "#content"
      controls: "#page-controls"
      titlebar: "#title-bar"

  return {
    Nav: Nav
    TitleBar: TitleBar
    Loading: Loading
    NotFound: NotFound
    Index: Index
    Layout: Layout
  }
