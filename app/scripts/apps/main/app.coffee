define [
  "app",
  "jquery",
  "components/views/main_layout",
  "components/views/main_nav",
  "components/views/login",
  "components/views/not_found",
  "entities"
], (App, $, MainLayout, MainNav, Login, NotFound, Entities) ->

  Main = App.module("Main")

  class Main.Router extends Marionette.AppRouter

    appRoutes:
      "": "login"
      "logout": "logout"
      ":store_id": "storeShow"
      "*default": "notFound"

    before: (route, args) ->
      @controller.layout = new MainLayout()

  class Main.Controller extends Marionette.Controller

    login: (opts) ->
      $.get(App.API_ROOT + "/store")
        .done ->
          # TODO: use @storeShow
          App.navigate('/38/pages', {trigger: true})
        .fail ->
          App.layout.show(new Login())

    logout: (opts) ->
      # App.layout.show(new Login())
      App.request("user:logout")

    ### TODO: decide where to put this, admin ?
    storeIndex: ->
      layout = new MainLayout()
      @region.show(layout)
      layout.nav.show(new MainNav(model: new Entities.Model(store: null, page: 'stores')))
      @setRegion(layout.content)

      stores = App.request "store:entities"

      App.execute "when:fetched", stores, =>
        App.setTitle("Stores")
        @region.show(new StoreIndex(model: stores))
    ###

    storeShow: (store_id) ->
      App.navigate("#{Backbone.history.getFragment()}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.layout.show(new NotFound())

  App.addInitializer ->
    controller = new Main.Controller()
    router = new Main.Router(controller: controller)

  Main
