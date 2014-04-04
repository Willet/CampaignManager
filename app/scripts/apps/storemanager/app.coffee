define [
  'app',
  'exports',
  'marionette',
  'components/views/main_layout',
  'components/views/main_nav',
  'components/views/title_bar',
  './controller'
], (App, StoreManager, Marionette, MainLayout, MainNav, TitleBar) ->

  class StoreManager.Router extends Marionette.AppRouter

    appRoutes:
      ":username/stores": "storeIndex"

    before: (route, args) ->
      App.currentController = @controller
      @setupMainLayout(route)

    setupMainLayout: () ->
      layout = new MainLayout()
      layout.on "render", =>
        layout.nav.show(new MainNav(model: new Entities.Model(store: null, page: 'stores')))
        layout.titlebar.show(new TitleBar(model: new Entities.Model()))

      @controller.setRegion layout.content
      App.layout.show layout
      layout

  App.addInitializer ->
    controller = new StoreManager.Controller()
    router = new StoreManager.Router(controller: controller)

  return StoreManager
