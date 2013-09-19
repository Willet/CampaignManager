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

  class Controller extends Marionette.Controller

    root: (opts) ->
      App.main.show(new MainViews.Index())

    storeIndex: ->
      stores = App.request "store:entities"

      App.execute "when:fetched", stores, ->
        App.setTitle("Stores")
        App.main.show(new MainViews.Index(model: stores))

    storeShow: (store_id) ->
      App.navigate("#{Backbone.history.getFragment()}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.main.show(new MainViews.NotFound())
      App.header.currentView.model.set(page: "notFound")
      App.titlebar.currentView.model.set(title: "404 - Page Not Found")


  App.addInitializer(->
    controller = new Controller()
    router = new Router(controller: controller)
    App.titlebar.show(new MainViews.TitleBar(model: App.pageInfo))
  )

  Main
