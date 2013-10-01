define [
  './app',
  'backbone.projections',
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
      @page = null
      pages = App.request "page:entities", store_id
      view = new Views.PageIndex model: pages, 'store-id': store_id
      all_models = null

      view.on 'change:filter', (filter) ->
        filtered_pages = _.filter(all_models, (m) -> (m.get("name") || "").search(filter) != -1)
        pages.reset(filtered_pages)

      view.on 'change:sort-order', (order) ->
        pages.updateSortBy order, (order == 'last-modified')

      view.on 'edit-most-recent', ->
        most_recent = _.max(all_models, (m) -> m.get('last-modified'))
        App.navigate("/#{store_id}/pages/#{most_recent.id}", trigger: true)

      view.on 'new-page', =>
        App.navigate("/#{store_id}/pages/new", trigger: true)

      App.execute "when:fetched", pages, =>
        all_models = _.clone(pages.models)
        @region.show view
        App.setTitle "Pages"

    getPage: (store_id, page_id) ->
      @page =
        if page_id == "new"
          if @page && @page.get('id') == null
            @page
          else
            @page = App.request "new:page:entity", store_id
        else
          if @page && @page.get('id') == page_id
            @page
          else
            App.request "page:entity", store_id, page_id

    pagesName: (store_id, page_id) ->
      page = @getPage(store_id, page_id)
      layout = new Views.PageCreateName(model: page)

      layout.on 'save', ->
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/content", trigger: true)

      App.execute "when:fetched", page, =>
        @region.show(layout)
        App.setTitle page.get("name")

    pagesLayout: (store_id, page_id) ->
      page = @getPage(store_id, page_id)

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
      page = @getPage(store_id, page_id)
      scrapes = App.request "page:scrapes:entities", store_id, page_id

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
      page = @getPage(store_id, page_id)
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