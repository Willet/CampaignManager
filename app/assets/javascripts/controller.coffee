define [
    "secondfunnel",
    "marionette",
    "views/main",
    "views/products",
    "views/content",
    "models/content"
  ], (SecondFunnel, Marionette, Main, Products, ContentViews, ContentModels) ->
    # Controller
    class Controller extends Marionette.Controller

      initialize: (opts) ->

      root: (opts) ->
        SecondFunnel.app.main.show(new Main.Index())

      productIndex: (store_id) ->
        SecondFunnel.app.main.show(new Products.Index())

      productShow: (store_id, content_id) ->
        SecondFunnel.app.main.show(new Products.Show())

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

