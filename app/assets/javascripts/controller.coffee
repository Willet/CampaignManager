define [
    "secondfunnel",
    "marionette",
    "views/main",
    "views/products",
    "views/content",
    "views/stores",
    "models/content",
    "models/stores"
  ], (SecondFunnel, Marionette, Main, Products, ContentViews, StoreViews, ContentModels, StoreModels) ->
    # Controller
    class Controller extends Marionette.Controller

      initialize: (opts) ->

      root: (opts) ->
        SecondFunnel.app.main.show(new Main.Index())

      productIndex: (store_id) ->
        SecondFunnel.app.main.show(new Products.Index())

      productShow: (store_id, content_id) ->
        SecondFunnel.app.main.show(new Products.Show())

      storeIndex: ->
        collection = new StoreModels.Collection()
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new StoreViews.Index(model: collection))
        )

      storeShow: (store_id)->
        model = new StoreModels.Model(id: store_id)
        model.fetch(success: ->
          SecondFunnel.app.main.show(new StoreViews.Show(model: model))
        )

      contentIndex: (store_id) ->
        collection = new ContentModels.Collection()
        collection.store_id = store_id
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new ContentViews.Index(model: collection))
        )

      contentShow: (store_id, content_id) ->
        model = new ContentModels.Model(id: content_id, store_id: store_id)
        model.fetch(success: ->
          SecondFunnel.app.main.show(new ContentViews.Show(model: model))
        )

