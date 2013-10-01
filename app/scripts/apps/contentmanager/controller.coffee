define [
  './app',
  'backbone.projections',
  'marionette',
  'jquery',
  'underscore',
  './views'
  'views/main',
  'components/views/content_list'
  'entities',
  './views/content_list',
  './views/edit_area',
  './views/index_layout',
  './views/list_controls',
  './views/quick_view',
  './views/tagged_inputs',
], (ContentManager, BackboneProjections, Marionette, $, _, Views, MainViews, ContentList, Entities) ->

  class ContentManager.Controller extends Marionette.Controller

    contentIndex: (store_id) ->
      store = App.request "store:entity", store_id
      App.execute "when:fetched", store, ->
        App.nav.show(new MainViews.Nav(model: new Entities.Model(store: store, page: 'content')))

      contents = App.request "content:entities:paged", store_id
      contents.getNextPage()

      App.execute "when:fetched", [contents], =>

        App.show ContentList.createView(contents)
        App.setTitle "Content"

  ContentManager
