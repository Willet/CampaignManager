define [
  './app',
  'backbone.projections',
  'marionette',
  'jquery',
  'underscore',
  './views',
  'components/views/content_list'
  'entities',
], (PageWizard, BackboneProjections, Marionette, $, _, Views, ContentList, Entities) ->

  class PageWizard.Controller extends Marionette.Controller

    pagesIndex: (store_id) ->
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

    pagesName: (store_id, page_id) ->
      page = App.routeModels.get('page')
      store = App.routeModels.get('store')
      layout = new Views.PageCreateName({model: page, store: store})
      layout.on 'save', ->
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/content", trigger: true)

      App.execute "when:fetched", page, =>
        App.execute "when:fetched", store, =>
          @region.show(layout)

    pagesLayout: (store_id, page_id) ->
      page = App.routeModels.get('page')

      layout =  new Views.PageCreateLayout(model: page)

      layout.on 'save', ->
        page.set('fields', layout.getFields())
        $.when(page.save()).done ->
          App.navigate("/#{store_id}/pages/#{page_id}/products", trigger: true)

      @region.show(layout)

    pagesProducts: (store_id, page_id) ->
      page = App.routeModels.get('page')
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

      @region.show layout

    pagesContent: (store_id, page_id) ->
      page = App.routeModels.get('page')
      contents = App.request "content:entities:paged", store_id, page_id

      layout = new Views.PageCreateContent(model: page)

      contents.getNextPage()

      layout.on "render", =>
        layout.contentList.show ContentList.createView(contents, { page: true })

      @region.show layout

    pagesView: (store_id, page_id) ->
      page = App.routeModels.get('page')

      @region.show new Views.PagePreview(model: page)

  PageWizard
