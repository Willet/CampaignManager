define ["marionette", "controller"], (Marionette, Controller) ->
  class Router extends Marionette.AppRouter
    controller: new Controller()

    appRoutes:
      "": "root"
      ":store_id/products": "productIndex"
      ":store_id/products/:id": "productShow"
      ":store_id/content": "contentIndex"
      ":store_id/content/:id": "contentShow"

    # standard not controller routes (call function in this router)
    routes: {}

