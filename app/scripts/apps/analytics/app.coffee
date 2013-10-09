define [
  'app',
  'exports'
], (App, ContentManager) ->

  class Analytics.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/analytics": "contentIndex"

  App.addInitializer ->
    controller = new ContentManager.Controller()
    router = new ContentManager.Router(controller: controller)

  return ContentManager
