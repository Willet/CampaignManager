define "app", [
  'marionette',
  'jquery',
  'underscore',
  'entities',
  'views/main',
  'components/regions/reveal'
], (Marionette, $, _, Entities, MainViews, Reveal) ->

  App = new Marionette.Application()

  App.rootRoute = "root"

  App.baseURI = window.appRoot
  App.appRoot = window.appRoot
  App.apiRoot = "#{App.appRoot}api"

  App.addRegions
    modal:
      selector: "#modal"
      regionType: Reveal.RevealDialog
    header: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"

  App.addInitializer ->
    App.header.show(new MainViews.Nav(model: new Backbone.Model(page: "none")))
    App.titlebar.show(new MainViews.TitleBar(model: new Backbone.Model({title: "Loading..."})))

    $(document).ajaxError (event, xhr) ->
      if (xhr.status == 401)
        redirectToLogin()

  App.on "initialize:after", (options) ->
    @startHistory()
    @navigate(@rootRoute, trigger: true) unless @getCurrentRoute()


  # Helpful for callback when a set of entities have been fetched
  App.commands.setHandler "when:fetched", (entities, callback) ->
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()
    $.when(xhrs...).done ->
      callback()

  App.global = {}

  App.currentStore = ->
    return App.global.currentStore

  App.setStore = (options) ->
    unless App.global.currentStore && App.global.currentStore.get("id") == options['id']
      store = App.global.currentStore = new Entities.Store.Model(id: options['id'])
      $.when(
        store.fetch()
      ).done(
        App.header.currentView.model.set(store: store)
      )

  class Router extends Marionette.AppRouter

    appRoutes:
      "": "storeIndex"
      ":store_id": "storeShow"

    # standard not controller routes (call function in this router)
    routes: {}

  class Controller extends Marionette.Controller

    root: (opts) ->
      App.main.show(new MainViews.Index())

    storeIndex: ->
      collection = new Entities.Store.Collection()
      collection.fetch(success: ->
        App.header.currentView.model.set(store: null)
        App.titlebar.currentView.model.set(title: "Stores")
        App.main.show(new MainViews.Index(model: collection))
      )

    storeShow: (store_id) ->
      App.navigate("#{Backbone.history.getFragment()}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.main.show(new MainViews.NotFound())
      App.header.currentView.model.set(page: "notFound")
      App.titlebar.currentView.model.set(title: "404 - Page Not Found")


  rootController = new Controller()
  rootRouter = new Router(controller: rootController)

  App
