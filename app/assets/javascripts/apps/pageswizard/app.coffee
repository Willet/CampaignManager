define [
  'app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  'views/pages',
  'views/contentmanager'
  'entities'
], (App, BackboneProjections, Marionette, $, _, Views, ContentViews, Entities) ->

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
      store = new Entities.Store(id: store_id)

      collection = new Entities.PageCollection()
      collection.store_id = store_id
      $.when(
        store.fetch(),
        collection.fetch()
      ).done(->
        App.main.show(new Views.PageIndex(model: collection))
        App.titlebar.currentView.model.set(title: "Pages")
        App.header.currentView.model.set(
          page: "pages"
          store: store
        )
      )

    pagesName: (store_id, id) ->
      store = new Entities.Store(id: store_id)
      model = new Entities.Page(id: id, "store-id": store_id)
      $.when(
        store.fetch(),
        model.fetch()
      ).done(->
        App.main.show(new Views.PageCreateName(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Name")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesLayout: (store_id, id) ->
      App.setStore(id: store_id)
      model = new Entities.Page(id: id, "store-id": store_id)
      $.when(
        model.fetch()
      ).done(->
        App.main.show(new Views.PageCreateLayout(model: model))
        App.titlebar.currentView.model.set(title: "Pages: #{model.get("name")} - Layout")
        App.header.currentView.model.set(page: "pages", store: store)
      )

    pagesProducts: (store_id, id) ->
      App.setStore(id: store_id)
      model = new Entities.Page(id: id, "store-id": store_id)
      $.when(
        model.fetch()
      ).done(->
        @layout = new Views.PageCreateProducts model: model

        @layout.on "show", =>
          @layout.contentList.show @contentList(collection)

        App.show @layout

        App.setTitle title: "Pages: #{model.get("name")} - Products"
      )


    contentList: (collection, actions) ->
      layout = new ContentViews.ContentIndexLayout()
      selectedCollection = new BackboneProjections.Filtered(collection, filter: ((m) -> m.get('selected') is true))

      contentList = new ContentViews.ContentList { collection: collection, actions: { page: true }}
      contentListControls = new ContentViews.ContentListControls()
      multiEditView = new ContentViews.ContentEditArea model: selectedCollection, actions: { page: true }

      #
      # Actions
      #

      layout.on "change:sort-order", (new_order) -> collection.updateSortOrder(new_order)

      contentListControls.on "change:state",
        (state) =>
          if state == "grid"
            layout.multiedit.$el.css("display", "block")
          else
            layout.multiedit.$el.css("display", "none")
          contentList.render()

      contentList.on "itemview:content:approve",
        (view, args) => args.model.approve()

      contentList.on "itemview:content:reject",
        (view, args)  => args.model.reject()

      contentList.on "itemview:content:undecided",
        (view, args)  => args.model.undecided()

      contentList.on "itemview:edit:tagged-products:add",
        (view, editArea, tagger, product) ->
          view.model.get('tagged-products').add(product)
          view.model.save()

      contentList.on "itemview:edit:tagged-products:remove",
        (view, editArea, tagger, product) ->
          view.model.get('tagged-products').remove(product)
          view.model.save()

      contentList.on "itemview:content:select-toggle",
        (view, args)  => args.model.set("selected", !args.model.get("selected"))

      contentList.on "itemview:content:preview",
        (view, args) => App.modal.show new ContentViews.ContentQuickView model: args.model

      multiEditView.on "content:approve",
        (args)  => args.model.collect((m) -> m.approve())

      multiEditView.on "content:reject",
        (args)  => args.model.collect((m) -> m.reject())

      multiEditView.on "content:undecided",
        (args)  => args.model.collect((m) -> m.undecided())

      layout.on("content:select-all", => collection.selectAll())
      layout.on("content:unselect-all", => collection.unselectAll())
      layout.on("fetch:next-page", => collection.getNextPage())

      #
      # Show
      #

      layout.on "show", ->
        layout.list.show contentList
        layout.listControls.show contentListControls
        layout.multiedit.show multiEditView

      return layout

    pagesContent: (store_id, id) ->
      App.setStore(id: store_id)
      model = new Entities.Page(id: id, "store-id": store_id)
      collection = new Entities.ContentPageableCollection()
      $.when(
        model.fetch(),
        collection.getNextPage()
      ).done(=>
        @layout = new Views.PageCreateContent(model: model)

        @layout.on "show", =>
          @layout.contentList.show @contentList(collection)

        App.show @layout
        App.setTitle "Pages: #{model.get("name")} - Content"
      )

    pagesView: (store_id, id) ->
      App.setStore(id: store_id)
      model = new Entities.Page(id: id, "store-id": store_id)
      $.when(
        model.fetch()
      ).done(->
        App.show new Views.PagePreview(model: model)
        App.setTitle "Pages: #{model.get("name")} - Preview"
      )


  App.addInitializer(->
    controller = new PageWizard.Controller()
    router = new PageWizard.Router(controller: controller)
  )

  PageWizard
