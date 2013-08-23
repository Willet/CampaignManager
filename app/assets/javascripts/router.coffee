define ["marionette", "controller"], (Marionette, Controller) ->
  class Router extends Marionette.AppRouter
    controller: new Controller()

    appRoutes:
      "": "storeIndex"
      ":store_id": "storeShow"
      ":store_id/products": "productIndex"
      ":store_id/products/:id": "productShow"
      ":store_id/content": "contentIndex"
      ":store_id/content/:id": "contentShow"
      ":store_id/campaigns": "campaignIndex"
      ":store_id/campaigns/:id": "campaignShow"

    # standard not controller routes (call function in this router)
    routes: {}

