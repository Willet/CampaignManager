define [
  'app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  'views/pages',
  'views/contentmanager',
  'views/main',
  'entities'
], (App, BackboneProjections, Marionette, $, _, Views, ContentViews, MainViews, Entities) ->

  PageWizard = App.module("PageWizard")

  class PageWizard.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/pages": "pagesIndex"
      ":store_id/pages/:id": "pagesName"
      ":store_id/pages/:id/layout": "pagesLayout"
      ":store_id/pages/:id/products": "pagesProducts"
      ":store_id/pages/:id/content": "pagesContent"
      ":store_id/pages/:id/view": "pagesView"

    before: (route, args) ->
      store_id = args[0]
      store = App.request "store:entity", store_id
      App.nav.show(new MainViews.Nav(model: new Entities.Model(store: store, page: 'pages')))
      @controller.setRegion(App.main)

  class PageWizard.Controller extends Marionette.Controller

    pagesIndex: (store_id) ->
      pages = App.request "page:entities", store_id

      App.execute "when:fetched", pages, =>
        @region.show(new Views.PageIndex(model: pages))

    pagesName: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      App.execute "when:fetched", page, =>
        @region.show(new Views.PageCreateName(model: page))
        App.setTitle("Pages: #{page.get("name")} - Name")

    pagesLayout: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      layout =  new Views.PageCreateLayout(model: page)

      layout.on 'layout:selected', (newLayout) ->
        page.set("layout", newLayout)
        layout.render()

      App.execute "when:fetched", page, =>
        @region.show(layout)
        App.setTitle("Pages: #{page.get("name")} - Layout")

    pagesProducts: (store_id, page_id) ->
      scrapes = App.request "page:scrapes:entities", store_id, page_id
      page = App.request "page:entity", store_id, page_id

      products = new Entities.ContentCollection
      layout = new Views.PageCreateProducts model: page

      layout.on "show", =>
        scrapeList = new Views.PageScrapeList collection: scrapes
        layout.scrapeList.show scrapeList
        layout.on "new:scrape", (url) ->
          scrape = new Entities.Scrape(store_id: store_id, page_id: page_id, url: url)
          scrapes.add(scrape)
          scrape.save()
        scrapeList.on "itemview:remove", (view) ->
          scrapes.remove(view.model)

      App.execute "when:fetched", page, =>
        App.show layout
        App.setTitle "Pages: #{page.get("name")} - Products"

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

    pagesContent: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id
      contents = App.request "content:entities:paged", store_id, page_id

      layout = new Views.PageCreateContent(model: page)

      contents.getNextPage()
      App.execute "when:fetched", [page, contents], =>

        layout.on "show", =>
          layout.contentList.show @contentList(contents)

        App.show layout
        App.setTitle "Pages: #{page.get("name")} - Content"

    pagesView: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      App.execute "when:fetched", page, =>
        App.show new Views.PagePreview(model: page)
        App.setTitle "Pages: #{page.get("name")} - Preview"


  App.addInitializer(->
    controller = new PageWizard.Controller()
    router = new PageWizard.Router(controller: controller)
  )

  PageWizard
