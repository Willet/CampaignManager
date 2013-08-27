define [
    "secondfunnel",
    "marionette",
    "views",
    "models"
  ], (SecondFunnel, Marionette, Views, Models) ->
    # Controller
    class Controller extends Marionette.Controller

      initialize: (opts) ->

      root: (opts) ->
        SecondFunnel.app.main.show(new Views.Main.Index())

      campaignIndex: (store_id) ->
        model = Models.Campaigns.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        collection = new Models.Products.Collection()
        collection.store_id = store_id
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Campaigns.Index(model: collection))
        )

      campaignShow: (store_id, id) ->
        model = Models.Campaigns.Model.findOrCreate(id: id, "store-id": store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model.fetch(complete: ->
          SecondFunnel.app.main.show(new Views.Campaigns.Show(model: model))
        )

      productIndex: (store_id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        collection = new Models.Products.Collection()
        collection.store_id = store_id

        $.when(
          store.fetch(),
          collection.fetch()
        ).then(->
          $.when.apply(@,
            collection.collect(
              (model) -> $.when.apply(@, model.fetchRelated("default-image-id", "store-id": store_id))
            )
          )
        ).done(->
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.main.show(new Views.Products.Index(model: collection))
        )

      productShow: (store_id, product_id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)

        model = Models.Products.Model.findOrCreate(id: product_id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).then(->
          $.when(
            $.when.apply(@, model.fetchRelated("default-image-id","store-id": store_id)),
            $.when.apply(@, model.fetchRelated("content-ids"))
          )
        ).done(->
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.main.show(new Views.Products.Show(model: model))
        )

      storeIndex: ->
        SecondFunnel.app.header.show(new Views.Main.Nav())
        collection = new Models.Store.Collection()
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Stores.Index(model: collection))
        )

      storeShow: (store_id)->
        model = Models.Store.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model.fetch(complete: ->
          SecondFunnel.app.main.show(new Views.Stores.Show(model: model))
        )

      contentIndex: (store_id) ->
        model = Models.Store.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        collection = new Models.Content.Collection()
        collection.store_id = store_id
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Content.Index(model: collection))
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
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.main.show(new Views.Content.Show(model: model))
        )

