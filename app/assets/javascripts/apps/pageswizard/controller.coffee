define [
  './app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  './views',
  '../contentmanager/views',
  'views/main',
  'components/views/content_list'
  'entities',
  './views/index',
  './views/content',
  './views/layout',
  './views/name',
  './views/products'
], (PageWizard, BackboneProjections, Marionette, $, _, Views, ContentViews, MainViews, ContentList, Entities) ->

  class PageWizard.Controller extends Marionette.Controller

    pagesIndex: (store_id) ->
      pages = App.request "page:entities", store_id

      App.execute "when:fetched", pages, =>
        @region.show(new Views.PageIndex(model: pages))
        App.setTitle "Pages"

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

    pagesContent: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id
      contents = App.request "content:entities:paged", store_id, page_id

      layout = new Views.PageCreateContent(model: page)

      contents.getNextPage()
      App.execute "when:fetched", [page, contents], =>

        layout.on "show", =>
          layout.contentList.show ContentList.createView(contents, { page: true })

        App.show layout
        App.setTitle page.get("name")

    pagesView: (store_id, page_id) ->
      page = App.request "page:entity", store_id, page_id

      App.execute "when:fetched", page, =>
        App.show new Views.PagePreview(model: page)
        App.setTitle page.get("name")

  PageWizard