define "app", [
  'backbone',
  'marionette',
  'jquery',
  'underscore',
  'models',
  'views/main',
  'components/regions/reveal'
], (Backbone, Marionette, $, _, Models, Views, Reveal) ->

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
      App.main.show(new Views.Index())

    storeIndex: ->
      collection = new Models.Store.Collection()
      collection.fetch(success: ->
        App.header.currentView.model.set(store: null)
        App.titlebar.currentView.model.set(title: "Stores")
        App.main.show(new Views.Index(model: collection))
      )

    storeShow: (store_id) ->
      Backbone.history.navigate("#{Backbone.history.getFragment()}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.main.show(new Views.NotFound())
      App.header.currentView.model.set(page: "notFound")
      App.titlebar.currentView.model.set(title: "404 - Page Not Found")


  rootController = new Controller()
  rootRouter = new Router(controller: rootController)

  App.on("initialize:after", ->
    if (Backbone.history && !Backbone.history.start({pushState: true, root: App.appRoot}))
      rootController.notFound()
  )

  App.addInitializer(->
    App.header.show(new Views.Nav(model: new Backbone.Model(page: "none")))
    App.titlebar.show(new Views.TitleBar(model: new Backbone.Model({title: "Loading..."})))
  )

  App.addRegions(
    modal:
      selector: "#modal"
      regionType: Reveal.RevealDialog
    header: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"
  )

  App
