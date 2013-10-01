define [
  "app",
  "views/main",
  "entities"
], (App, MainViews, Entities) ->

  Main = App.module("Main")

  class Router extends Marionette.AppRouter

    appRoutes:
      "": "storeIndex"
      ":store_id": "storeShow"
      "*default": "notFound"

  class Controller extends Marionette.Controller

    root: (opts) ->
      App.main.show(new MainViews.Index())

    storeIndex: ->
      @setRegion(App.layout)
      layout = new MainViews.Layout()
      @region.show(layout)
      layout.nav.show(new MainViews.Nav(model: new Entities.Model(store: null, page: 'stores')))
      @setRegion(layout.content)

      stores = App.request "store:entities"

      App.execute "when:fetched", stores, =>
        App.setTitle("Stores")
        @region.show(new MainViews.Index(model: stores))

    storeShow: (store_id) ->
      App.navigate("#{Backbone.history.getFragment()}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.layout.show(new MainViews.NotFound())

  App.addInitializer(->
    controller = new Controller()
    router = new Router(controller: controller)
    #App.titlebar.show(new MainViews.TitleBar(model: App.pageInfo))
  )

  Main
