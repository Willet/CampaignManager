define [
  'app',
  './app',
  './list_views',
  '../views',
  'backboneprojections'
], (App, ContentManager, Views, ContentViews, BackboneProjections) ->

  class ContentManager.Controller extends App.Controllers.Base

    contentIndex: () ->
      store = App.routeModels.get 'store'
      contents = App.request "content:all", store

      layout = new MainLayout()

      App.execute "when:fetched", store, =>
        layout.nav.show(new MainNav(model: new Entities.Model(store: store, page: 'content')))

      App.execute "when:fetched", contents, =>
        layout.content.show @getContentListView(contents)

      @show layout

  getContentListView: (contents) ->

    layout = new ContentViews.ContentIndexLayout initial_state: 'grid'
    selectedCollection = new BackboneProjections.Filtered(contents, filter: ((m) -> m.get('selected') is true))

    contentList = new ContentViews.ContentList { collection: contents, actions: actions }
    contentListControls = new ContentViews.ContentListControls()
    multiEditView = new ContentViews.ContentEditArea model: selectedCollection, actions: actions, multiEdit: true

    #
    # Actions
    #

    layout.on 'change:sort-order', (new_order) -> contents.updateSortOrder(new_order)

    contentList.on 'itemview:content:approve',
      (view, args) =>
        content = args.model
        App.request('content:approve', content)
        args.view.render()

    contentList.on 'itemview:content:reject',
      (view, args)  =>
        content = args.model
        App.request('content:reject', content)
        args.view.render()

    contentList.on 'itemview:content:undecided',
      (view, args)  =>
        content = args.model
        App.request('content:undecide', content)
        args.view.render()

    contentList.on 'itemview:edit:tagged-products:add',
      (view, editArea, tagger, product) ->
        view.model.get('tagged-products').add(product)
        view.model.save()

    contentList.on 'itemview:edit:tagged-products:remove',
      (view, editArea, tagger, product) ->
        view.model.get('tagged-products').remove(product)
        view.model.save()

    contentList.on 'itemview:content:select-toggle',
      (view, args)  =>
        content = args.model
        content.set('selected', !args.model.get('selected'))

    contentList.on 'itemview:content:preview',
      (view, args) =>
        content = args.model
        App.modal.show(new ContentViews.ContentQuickView({model: content}))

    multiEditView.on 'content:approve',
      (args)  =>
        contentCollection = args.model
        contentCollection.collect((m) -> App.request('content:approve', m))
        contentModels = _.clone(args.model.models)
        _.each(contentModels, (m) -> m.set('selected', false))

    multiEditView.on 'content:reject',
      (args)  =>
        contentCollection = args.model
        contentCollection.collect((m) -> App.request('content:reject', m))
        contentModels = _.clone(args.model.models)
        _.each(contentModels, (m) -> m.set('selected', false))

    multiEditView.on 'content:undecided',
      (args)  =>
        contentCollection = args.model
        contentCollection.collect((m) -> App.request('content:undecide', m))
        contentModels = _.clone(args.model.models)
        _.each(contentModels, (m) -> m.set('selected', false))

    layout.on('content:select-all', => collection.selectAll())
    layout.on('content:unselect-all', => collection.unselectAll())
    layout.on('fetch:next-page', () =>
        collection.getNextPage()
        layout.trigger('fetch:next-page:complete')
    )

    layout.on 'show', ->
      layout.list.show contentList
      layout.listControls.show contentListControls
      layout.multiedit.show multiEditView

    return layout

  ContentManager
