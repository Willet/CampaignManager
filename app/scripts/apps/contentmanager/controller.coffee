define [
  'app',
  './app',
  'backbone.projections',
  'marionette',
  'jquery',
  'underscore',
  './views'
  'components/views/main_layout',
  'components/views/main_nav',
  'components/views/content_list'
  'entities',
  './views/content_list',
  './views/edit_area',
  './views/index_layout',
  './views/list_controls',
  './views/quick_view',
  './views/tagged_inputs',
], (App, ContentManager, BackboneProjections, Marionette, $, _, Views, MainLayout, MainNav, ContentList, Entities) ->

  class ContentManager.Controller extends App.Controllers.Base

    contentIndex: () ->
      store = App.routeModels.get('store')
      contents = App.request "content:all", store

      layout = new MainLayout()

      App.execute "when:fetched", store, =>
        layout.nav.show(new MainNav(model: new Entities.Model(store: store, page: 'content')))

      App.execute "when:fetched", contents, =>
        layout.content.show ContentList.createView(contents)

      @show layout

  ContentManager
