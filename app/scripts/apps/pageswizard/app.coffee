define [
  'app'
  'exports',
  'marionette',
  './views',
  'views/main',
  'entities',
  './controller'
], (App, PageWizard, Marionette, Views, MainViews, Entities) ->

  class PageWizard.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/pages": "pagesIndex"
      ":store_id/pages/:page_id": "pagesName"
      ":store_id/pages/:page_id/layout": "pagesLayout"
      ":store_id/pages/:page_id/products": "pagesProducts"
      ":store_id/pages/:page_id/content": "pagesContent"
      ":store_id/pages/:page_id/view": "pagesView"

    setupModels: (route, args) ->
      @setupRouteModels(route, args)
      @store = App.routeModels.get('store')
      @page = App.routeModels.get('page')

    # build parameters into a map
    parameterMap: (route, args) ->
      params = {}
      matches = route.match(/:[a-zA-Z_-]+/g)
      for match, i in matches
        params[match.replace(/^:/, '')] = args[i]
      params

    # For a given route, extracts the parameters
    # and builds the related Models to that route
    setupRouteModels: (route, args) ->
      # extract any parameters in the route
      params = @parameterMap route, args
      console.log params
      matches = route.match(/:[a-zA-Z_-]+/g)
      App.routeModels = App.routeModels || new Backbone.Model()
      for match, i in matches
        entityRequestName = @paramNameMapping(match)
        # NOTE: Assumes all arguments from the list are valid
        model = App.request entityRequestName, params
        name = @routeModelNameMapping(match)
        App.routeModels.set name, model
      App.routeModels

    # determines the name of what the route model should
    # be given the parameter name in the route
    routeModelNameMapping: (param_name) ->
      # strip the id off the end
      switch param_name
        when ":store_id" then "store"
        when ":page_id" then "page"
        else param_name

    # Given a parameter e.g. :store_id
    # extract the App request it should make
    paramNameMapping: (param_name) ->
      switch param_name
        when ":store_id" then "store:entity"
        when ":page_id" then "page:entity"
        else param_name

    before: (route, args) ->
      App.currentController = @controller
      @setupModels(route, args)
      @setupMainLayout(route)
      @setupLayoutForRoute(route)

    setupMainLayout: () ->
      layout = new MainViews.Layout()
      layout.on "render", =>
        layout.nav.show(new MainViews.Nav(model: new Entities.Model(store: @store, page: 'pages')))
        layout.titlebar.show(new MainViews.TitleBar(model: new Entities.Model()))

      @controller.setRegion layout.content
      App.layout.show layout
      layout

    setupLayoutForRoute: (route) ->
      if route.indexOf(":store_id/pages/:page_id") == 0
        layout = @setupPageWizardLayout(route)

    setupPageWizardLayout: (route) ->
      @page_wizard_layout = layout = new Views.PageWizardLayout()
      layout.on "render", =>
        routeSuffix = route.substring(_.lastIndexOf(route,'/')).replace(/^\//,'')
        routeSuffix = if routeSuffix == ":page_id" then "name" else routeSuffix
        layout.header.show(new Views.PageHeader(model: new Entities.Model(page: routeSuffix), store: @store, page: @page))
      @controller.region.show(layout)
      @controller.setRegion(layout.content)
      @page_wizard_layout

  App.addInitializer ->
    controller = new PageWizard.Controller()
    router = new PageWizard.Router(controller: controller)

  PageWizard
