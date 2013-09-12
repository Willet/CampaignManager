define [
  'app',
  'marionette',
  'jquery',
  'underscore',
  'views/contentmanager',
  'models/content',
  'models/stores'
], (App, Marionette, $, _, Views, ContentEntities, StoreEntities) ->

  ContentManager = App.module("ContentManager")

  class ContentManager.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/content": "contentIndex"
      ":store_id/content/:id": "contentShow"

  class ContentManager.Controller extends Marionette.Controller

    contentIndex: (store_id) ->
      App.setStore(id: store_id)
      collection = new ContentEntities.PageableCollection()
      collection.store_id = store_id
      $.when(
        collection.getNextPage()
      ).done(->
        App.main.show(new Views.Index(model: collection))
        App.titlebar.currentView.model.set({title: "Content"})
        App.header.currentView.model.set(page: "content")
      )

    contentShow: (store_id, content_id) ->
      App.setStore(id: store_id)

      model = new ContentEntities.Model(id: content_id, "store-id": store_id)
      model.set("store-id", store_id)

      $.when(
        model.fetch()
      ).done(=>
        App.main.show(new Views.Show(model: model))
        App.titlebar.currentView.model.set(title: "Content: #{model.get("title") || ""}")
        App.header.currentView.model.set(page: "content")
      )

  App.addInitializer(->
    controller = new ContentManager.Controller()
    router = new ContentManager.Router(controller: controller)
  )

  return ContentManager
