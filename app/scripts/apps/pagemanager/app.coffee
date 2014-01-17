define ["app", "exports", "backbone", "marionette", "./views", "entities",
  "./controller", "components/views/main_layout", "components/views/main_nav",
  "components/views/title_bar", "underscore"], (App, PageManager, Backbone,
  Marionette, Views, Entities, Controller, MainLayout, MainNav, TitleBar, _) ->
  "use strict"

  class PageManager.Router extends Marionette.AppRouter
    appRoutes:
      ":store_id/pages": "pagesIndex"
      ":store_id/pages/:page_id": "pagesName"
      ":store_id/pages/:page_id/layout": "pagesLayout"
      ":store_id/pages/:page_id/products": "pagesProducts"
      ":store_id/pages/:page_id/content": "pagesContent"
      ":store_id/pages/:page_id/view": "pagesView"
      ":store_id/pages/:page_id/publish": "publishView"
      ":store_id/pages/:page_id/preview": "previewView"

    setupModels: (route, args) ->
      @setupRouteModels route, args
      @store = App.routeModels.get("store")
      @page = App.routeModels.get("page")

    parameterMap: (route, args) ->
      params = {}
      matches = route.match(/:[a-zA-Z_-]+/g)

      for match, i in matches
        params[match.replace(/^:/, "").replace(/-/, "_")] = args[i]
      params

    setupRouteModels: (route, args) ->
      entityRequestName = undefined
      i = undefined
      match = undefined
      matches = undefined
      model = undefined
      name = undefined
      params = undefined
      _i = undefined
      _len = undefined
      
      # params = e.g. {store_id: "38", page_id: "97"}
      params = @parameterMap(route, args)
      
      # find what the route captures
      matches = route.match(/:[a-zA-Z_-]+/g)
      App.routeModels = App.routeModels or new Backbone.Model()
      i = _i = 0
      _len = matches.length

      while _i < _len
        match = matches[i] # e.g. ':store_id'
        
        # e.g. turn capture into request name, e.g. 'store:entity'
        entityRequestName = @paramNameMapping(match)
        
        # makes a request for the object, e.g. Store
        model = App.request(entityRequestName, params)
        
        # name = e.g. 'store'
        name = @routeModelNameMapping(match)
        App.routeModels.set name, model
        i = ++_i
      App.routeModels

    routeModelNameMapping: (paramName) ->
      switch paramName
        when ":store_id"
          "store"
        when ":page_id"
          "page"
        else
          paramName

    
    ###
    Turns a "capture group" into its entity request name.
    @param {string} paramName
    @returns {*}
    ###
    paramNameMapping: (paramName) ->
      switch paramName
        when ":store_id"
          "store:get"
        when ":page_id"
          "page:get"
        else
          paramName

    before: (route, args) ->
      App.currentController = @controller
      @setupModels route, args
      @setupMainLayout route
      @setupLayoutForRoute route

    setupMainLayout: ->
      _this = this
      layout = new MainLayout()
      layout.on "render", ->
        layout.nav.show new MainNav(model: new Entities.Model(
          store: _this.store
          page: "pages"
        ))
        layout.titlebar.show new TitleBar(model: new Entities.Model())

      @controller.setRegion layout.content
      App.layout.show layout
      layout

    setupLayoutForRoute: (route) ->
      layout = @setupPageManagerLayout(route)  if route.indexOf(":store_id/pages/:page_id") is 0

    setupPageManagerLayout: (route) ->
      _this = this
      @pageManagerLayout = layout = new Views.PageManagerLayout()
      layout.on "render", ->
        routeSuffix = undefined
        routeSuffix = route.substring(_.lastIndexOf(route, "/")).replace(/^\//, "")
        routeSuffix = (if routeSuffix is ":page_id" then "name" else routeSuffix)
        layout.header.show new Views.PageHeader(
          model: new Entities.Model(page: routeSuffix)
          store: _this.store
          page: _this.page
        )

      @controller.region.show layout
      @controller.setRegion layout.content
      @pageManagerLayout

  App.addInitializer ->
    controller = new PageManager.Controller()
    router = new PageManager.Router(controller: controller)

  PageManager
