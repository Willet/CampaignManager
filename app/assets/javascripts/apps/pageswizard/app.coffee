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
      ":store_id/pages/:id": "pagesName"
      ":store_id/pages/:id/layout": "pagesLayout"
      ":store_id/pages/:id/products": "pagesProducts"
      ":store_id/pages/:id/content": "pagesContent"
      ":store_id/pages/:id/view": "pagesView"

    before: (route, args) ->
      store_id = args[0]
      store = App.request "store:entity", store_id
      App.execute "when:fetched", store, ->
        App.nav.show(new MainViews.Nav(model: new Entities.Model(store: store, page: 'pages')))
      @controller.setRegion(App.main)

  App.addInitializer(->
    controller = new PageWizard.Controller()
    router = new PageWizard.Router(controller: controller)
  )

  PageWizard
