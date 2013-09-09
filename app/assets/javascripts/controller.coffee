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

      notFound: (opts) ->
        SecondFunnel.app.main.show(new Views.Main.NotFound())
        SecondFunnel.app.header.currentView.model.set(page: "notFound")
        SecondFunnel.app.titlebar.currentView.model.set(title: "404 - Page Not Found")

      pagesIndex: (store_id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)

        collection = new Models.Pages.Collection()
        collection.store_id = store_id
        $.when(
          store.fetch(),
          collection.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Pages.Index(model: collection))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Pages")
          SecondFunnel.app.header.currentView.model.set(
            page: "pages"
            store: store
          )
        )

      pagesName: (store_id, id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        model = Models.Pages.Model.findOrCreate(id: id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Pages.Name(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Pages")
          SecondFunnel.app.header.currentView.model.set(page: "pages", store: store)
        )

      pagesLayout: (store_id, id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        model = Models.Pages.Model.findOrCreate(id: id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Pages.Layout(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Pages")
          SecondFunnel.app.header.currentView.model.set(page: "pages", store: store)
        )

      pagesProducts: (store_id, id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        model = Models.Pages.Model.findOrCreate(id: id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Pages.Products(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Pages")
          SecondFunnel.app.header.currentView.model.set(page: "pages", store: store)
        )

      pagesContent: (store_id, id) ->
        store = Models.Store.Model.findOrCreate(id: store_id)
        model = Models.Pages.Model.findOrCreate(id: id, "store-id": store_id)
        $.when(
          store.fetch(),
          model.fetch()
        ).done(->
          SecondFunnel.app.main.show(new Views.Pages.Content(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Pages")
          SecondFunnel.app.header.currentView.model.set(page: "pages", store: store)
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
          SecondFunnel.app.header.currentView.model.set(store: store)
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
          SecondFunnel.app.main.show(new Views.Products.Show(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Product: #{model.get("name")}")
          SecondFunnel.app.header.currentView.model.set(store: store)
        )

      storeIndex: ->
        SecondFunnel.app.header.currentView.model.set(store: null)
        collection = new Models.Store.Collection()
        collection.fetch(success: ->
          SecondFunnel.app.main.show(new Views.Stores.Index(model: collection))
        )

      storeShow: (store_id)->
        @pagesIndex(store_id)
        #model = Models.Store.Model.findOrCreate(id: store_id)
        #SecondFunnel.app.header.show(new Views.Main.Nav(store: model))
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
          SecondFunnel.app.titlebar.currentView.model.set({title: "Content"})
          SecondFunnel.app.header.currentView.model.set(page: "content", store: store)
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
          SecondFunnel.app.main.show(new Views.Content.Show(model: model))
          SecondFunnel.app.titlebar.currentView.model.set(title: "Content: #{model.get("title") || ""}")
          SecondFunnel.app.header.currentView.model.set(page: "content", store: store)
        )

