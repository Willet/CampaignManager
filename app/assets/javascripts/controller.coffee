define [
    "secondfunnel",
    "marionette",
    "views",
    "models/content",
    "models/stores"
  ], (SecondFunnel, Marionette, Views, ContentModels, StoreModels) ->
    # Controller
    class Controller extends Marionette.Controller

      initialize: (opts) ->

      root: (opts) ->
        SecondFunnel.app.main.show(new Views.Main.Index())

      productIndex: (store_id) ->
        model = StoreModels.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        SecondFunnel.app.main.show(new Views.Products.Index())

      productShow: (store_id, content_id) ->
        model = StoreModels.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        SecondFunnel.app.main.show(new Views.Products.Show())

      storeIndex: ->
        SecondFunnel.app.header.show(new Views.Main.Nav())
        collection = new StoreModels.Collection()
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Stores.Index(model: collection))
        )

      storeShow: (store_id)->
        model = StoreModels.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Stores.Show(model: model))
        )

      contentIndex: (store_id) ->
        model = StoreModels.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        collection = new ContentModels.Collection()
        collection.store_id = store_id
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Content.Index(model: collection))
        )

      contentShow: (store_id, content_id) ->
        model = StoreModels.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model = new ContentModels.Model(id: content_id, store_id: store_id)
        model.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Content.Show(model: model))
        )

