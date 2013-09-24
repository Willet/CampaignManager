define [
  './app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  './views',
  '../contentmanager/views',
  'views/main',
  'entities',
  './views/index',
  './views/content',
  './views/layout',
  './views/name',
  './views/products'
], (PageWizard, BackboneProjections, Marionette, $, _, Views, ContentViews, MainViews, Entities) ->

  class PageWizard.Controller extends Marionette.Controller

    pagesIndex: (store_id) ->
      pages = App.request "page:entities", store_id

      App.execute "when:fetched", pages, =>
        @region.show(new Views.PageIndex(model: pages))

    pagesName: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id
      layout = new Views.PageCreateName(model: page)

      layout.on 'save', ->
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/content", trigger: true)

      App.execute "when:fetched", page, =>
        @region.show(layout)
        App.setTitle page.get("name")

    pagesLayout: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      layout =  new Views.PageCreateLayout(model: page)

      layout.on 'layout:selected', (newLayout) ->
        page.set("layout", newLayout)
        layout.render()

      layout.on 'save', ->
        page.set('fields', layout.getFields())
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/products", trigger: true)

      App.execute "when:fetched", page, =>
        @region.show(layout)
        App.setTitle page.get("name")

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

      layout.on 'save', ->
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/content", trigger: true)

      App.execute "when:fetched", page, =>
        App.show layout
        App.setTitle page.get("name")

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
        (args)  =>
         args.model.collect((m) -> m.approve())
         models = _.clone(args.model.models)
         _.each(models, (m) -> m.set('selected', false))

      multiEditView.on "content:reject",
        (args)  =>
         args.model.collect((m) -> m.reject())
         models = _.clone(args.model.models)
         _.each(models, (m) -> m.set('selected', false))

      multiEditView.on "content:undecided",
        (args)  =>
         args.model.collect((m) -> m.undecided())
         models = _.clone(args.model.models)
         _.each(models, (m) -> m.set('selected', false))

      layout.on("content:select-all", => collection.selectAll())
      layout.on("content:unselect-all", => collection.unselectAll())
      layout.on("fetch:next-page", =>
        $.when(collection.getNextPage()).done =>
          layout.trigger("fetch:next-page:complete")
      )

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
        App.setTitle page.get("name")

    pagesView: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      App.execute "when:fetched", page, =>
        App.show new Views.PagePreview(model: page)
        App.setTitle page.get("name")

  PageWizard