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
        store = Models.Store.Model.findOrCreate(id: store_id)

        # TODO: currently listing products (instead of campaigns/pages)
        collection = new Models.Products.Collection()
        collection.store_id = store_id
        $.when(
          store.fetch(),
          collection.fetch()
        ).done(->
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.main.show(new Views.Campaigns.Index(model: collection))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Campaigns")
          SecondFunnel.app.titlebar.currentView.render()
        )

      campaignShow: (store_id, id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        model = Models.Campaigns.Model.findOrCreate(id: id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).done(->
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.main.show(new Views.Campaigns.Show(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Campaign: #{model.get('name')}")
          SecondFunnel.app.titlebar.currentView.render()
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
          SecondFunnel.app.titlebar.currentView.model.set(title: "Product: #{model.get("name")}")
          SecondFunnel.app.titlebar.currentView.render()
        )

      storeIndex: ->
        SecondFunnel.app.header.show(new Views.Main.Nav())
        collection = new Models.Store.Collection()
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Stores.Index(model: collection))
        )

      storeShow: (store_id)->
        @campaignIndex(store_id)
        #model = Models.Store.Model.findOrCreate(id: store_id)
        #SecondFunnel.app.header.show(new Views.Main.Nav(model: model))
        #model.fetch(complete: ->
        #  SecondFunnel.app.main.show(new Views.Stores.Show(model: model))
        #  SecondFunnel.app.titlebar.currentView.model.set({title: model.get("name")})
        #  SecondFunnel.app.titlebar.currentView.render()
        #)

      contentIndex: (store_id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        collection = new Models.Content.Collection()
        collection.store_id = store_id
        $.when(
          store.fetch(),
          collection.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Content.Index(model: collection))
          SecondFunnel.app.header.show(new Views.Main.Nav(model: store))
          SecondFunnel.app.titlebar.currentView.model.set({title: "Content"})
          SecondFunnel.app.titlebar.currentView.render()
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
          SecondFunnel.app.titlebar.currentView.model.set(title: "Content: #{model.get("title") || ""}")
          SecondFunnel.app.titlebar.currentView.render()
        )

