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
        model = Models.Campaigns.Model.findOrCreate(id: id, store_id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model.fetch(complete: ->
          SecondFunnel.app.main.show(new Views.Campaigns.Show(model: model))
        )

      productIndex: (store_id) ->
        model = Models.Store.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))

        collection = new Models.Products.Collection()
        collection.store_id = store_id
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Products.Index(model: collection))
        )

      productShow: (store_id, product_id) ->
        model = Models.Store.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))

        model = Models.Products.Model.findOrCreate(id: product_id, store_id: store_id)
        model.fetch(complete: -> # grumble grumble
          model.fetchRelated("content-ids", complete: -> # TODO: grumble grumble
            SecondFunnel.app.main.show(new Views.Products.Show(model: model))
          )
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
        model = Models.Store.Model.findOrCreate(id: store_id)
        SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        model = Models.Content.Model.findOrCreate(id: content_id, store_id: store_id)
        model.fetch(complete: ->
          model.fetchRelated("product-ids")
          SecondFunnel.app.main.show(new Views.Content.Show(model: model))
        )

