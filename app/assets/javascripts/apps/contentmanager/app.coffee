define [
  'app',
  'backbone'
  'marionette',
  'jquery',
  'underscore',
  'views/contentmanager'
], (App, Backbone, Marionette, $, _, Views) ->

  ContentManager = App.module("ContentManager")

  class ContentManager.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/content": "contentIndex"
      ":store_id/content/:id": "contentShow"

  class ContentManager.Controller extends Marionette.Controller

    contentIndex: (store_id) ->
      store = Models.Store.Model.findOrCreate(id: store_id)
      collection = new Models.Content.Collection()
      collection.store_id = store_id
      $.when(
        store.fetch(),
        collection.fetch()
      ).done(->
        App.main.show(new Views.Index(model: collection))
        App.titlebar.currentView.model.set({title: "Content"})
        App.header.currentView.model.set(page: "content", store: store)
      )

    contentShow: (store_id, content_id) ->
      store = Models.Store.Model.findOrCreate(id: store_id)

      model = Models.Content.Model.findOrCreate(id: content_id, "store-id": store_id)
      model.set("store-id", store_id)

      $.when(
        store.fetch(),
        model.fetch()
      ).then(->
        $.when.apply(@, model.fetchRelated("product-ids"))
      ).then(->
        $.when.apply(@,
          model.get("product-ids").collect((m) =>
            $.when.apply(@, m.fetchRelated("default-image-id", "store-id": store_id))
          )
        )
      ).done(=>
        App.main.show(new Views.Show(model: model))
        App.titlebar.currentView.model.set(title: "Content: #{model.get("title") || ""}")
        App.header.currentView.model.set(page: "content", store: store)
      )

  App.addInitializer(->
    controller = new ContentManager.Controller()
    router = new ContentManager.Router(controller: controller)
  )

  return ContentManager
