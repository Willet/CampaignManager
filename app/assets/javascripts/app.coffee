define "app", [
  'backbone',
  'marionette',
  'jquery',
  'underscore',
  'models',
  'views',
  'regions'
], (Backbone, Marionette, $, _, Models, Views, Regions) ->

  App = new Marionette.Application()
  App.appRoot = window.appRoot
  App.apiRoot = "#{App.appRoot}api"

  class Router extends Marionette.AppRouter

    appRoutes:
      "": "storeIndex"
      ":store_id": "storeShow"

    # standard not controller routes (call function in this router)
    routes: {}

  class Controller extends Marionette.Controller

    root: (opts) ->
      App.main.show(new Views.Main.Index())

    storeIndex: ->
      collection = new Models.Store.Collection()
      collection.fetch(success: ->
        App.header.currentView.model.set(store: null)
        App.main.show(new Views.Stores.Index(model: collection))
      )

    storeShow: (store_id) ->
      window.location = window.location + "/pages"

    notFound: (opts) ->
      App.main.show(new Views.Main.NotFound())
      App.header.currentView.model.set(page: "notFound")
      App.titlebar.currentView.model.set(title: "404 - Page Not Found")


  App.addInitializer(->
    rootController = new Controller()
    rootRouter = new Router(controller: rootController)
  )

  App.on("initialize:after", ->
    if (Backbone.history && !Backbone.history.start({pushState: true, root: App.appRoot}))
      rootRouter.trigger('notFound')
  )

  App.addInitializer(->
    App.header.show(new Views.Main.Nav(model: new Backbone.Model(page: "none")))
    App.titlebar.show(new Views.Main.TitleBar(model: new Backbone.Model({title: "Loading..."})))
  )

  App.addRegions(
    modal:
      selector: "#modal"
      regionType: Regions.RevealDialog
    header: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"
  )

  App
