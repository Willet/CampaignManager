define ["marionette", "controller"], (Marionette, Controller) ->
  class Router extends Marionette.AppRouter
    controller: new Controller()

    appRoutes:
      "": "root"
      "products": "productIndex"
      "products/:id": "productShow"

    # standard not controller routes (call function in this router)
    routes: {}

