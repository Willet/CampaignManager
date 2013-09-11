define [
  'app',
  'backbone'
  'marionette',
  'jquery',
  'underscore',
  'views/pages',
  'models'
], (App, Backbone, Marionette, $, _, Views, Models) ->

  PageWizard = App.module("PageWizard")

  class PageWizard.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/pages": "pagesIndex"
      ":store_id/pages/:id": "pagesName"
      ":store_id/pages/:id/layout": "pagesLayout"
      ":store_id/pages/:id/products": "pagesProducts"
      ":store_id/pages/:id/content": "pagesContent"
      ":store_id/pages/:id/view": "pagesView"

  class PageWizard.Controller extends Marionette.Controller

    pagesIndex: (store_id) ->
      store = new Models.Store.Model(id: store_id)

      collection = new Models.Pages.Collection()
      collection.store_id = store_id
      $.when(
        store.fetch(),
        collection.fetch()
      ).done(->
        App.main.show(new Views.Index(model: collection))
        App.titlebar.currentView.model.set(title: "Pages")
        App.header.currentView.model.set(
          page: "pages"
          store: store
        )
      )

    pagesName: (store_id, id) ->
      store = new Models.Store.Model(id: store_id)
      model = new Models.Pages.Model(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.Name(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Name")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesLayout: (store_id, id) ->
      store = new Models.Store.Model(id: store_id)
      model = new Models.Pages.Model(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.Layout(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Layout")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesProducts: (store_id, id) ->
      store = new Models.Store.Model(id: store_id)
      model = new Models.Pages.Model(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.Products(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Products")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesContent: (store_id, id) ->
      store = new Models.Store.Model(id: store_id)
      model = new Models.Pages.Model(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.Content(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Content")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesView: (store_id, id) ->
      store = new Models.Store.Model(id: store_id)
      model = new Models.Pages.Model(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.View(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Preview")
        App.header.currentView.model.set(page: "pages", store: store)
      )


  App.addInitializer(->
    controller = new PageWizard.Controller()
    router = new PageWizard.Router(controller: controller)
  )

  return PageWizard
