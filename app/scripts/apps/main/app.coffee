define [
  'app',
  'jquery',
  'components/views/main_layout',
  'components/views/main_nav',
  'components/views/login',
  'components/views/not_found',
  'entities'
], (App, $, MainLayout, MainNav, Login, NotFound, Entities) ->

  Main = App.module('Main')

  class Main.Router extends Marionette.AppRouter

    appRoutes:
      '': 'login'
      'logout': 'logout'
      ':username': 'storesShow'
      ':store_id': 'storeShow'
      '*default': 'notFound'

    before: (route, args) ->
      @controller.layout = new MainLayout()

  class Main.Controller extends Marionette.Controller

    login: (opts) ->
      self = @
      # length 0 if not logged in (HTTP 200)
      # .objects = length 1 if logged in (HTTP 200)
      $.get(App.API_ROOT + '/user/?format=json')
        .done (data) ->
          if data.objects.length
            username = data.objects[0].username
            # length 0 if username is not a store slug
            $.get(App.API_ROOT + '/store')
              .done (data) ->
                console.log data
                if data.results.length > 1
                  self.storesShow username
                else if data.results.length
                  self.storeShow data.results[0].id  # store id, e.g. 126
                else
                  App.layout.show(new NotFound())
          else  # no user info = not logged in
            App.layout.show(new Login())

    logout: (opts) ->
      App.request('user:logout').done () ->
          App.navigate('/', trigger: true)

    storesShow: (username) ->
      App.navigate("/#{username}/stores", trigger: true, replace: true)

    storeShow: (store_id) ->
      App.navigate("/#{store_id}/pages", trigger: true, replace: true)

    notFound: (opts) ->
      App.layout.show(new NotFound())

  App.addInitializer ->
    controller = new Main.Controller()
    router = new Main.Router(controller: controller)

  Main
