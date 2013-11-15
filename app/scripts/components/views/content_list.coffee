define [
  'exports'
  'backbone.projections',
  'underscore',
  'apps/contentmanager/views',
  'app'
], (ContentList, BackboneProjections, _, ContentViews, App) ->

  ContentList.createView = (collection, actions = {}) ->

    layout = new ContentViews.ContentIndexLayout initial_state: 'grid'
    selectedCollection = new BackboneProjections.Filtered(collection, filter: ((m) -> m.get('selected') is true))

    contentList = new ContentViews.ContentList { collection: collection, actions: actions }
    contentListControls = new ContentViews.ContentListControls()
    multiEditView = new ContentViews.ContentEditArea model: selectedCollection, actions: actions, multiEdit: true

    #
    # Actions
    #

    layout.on 'change:sort-order', (new_order) -> collection.updateSortOrder(new_order)

    # hide/show multi-edit on grid/list view
    contentListControls.on 'change:state',
      (state) =>
        if state == 'grid'
          layout.multiedit.$el.css('display', 'block')
        else
          layout.multiedit.$el.css('display', 'none')

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
    layout.on('fetch:next-page',
      () =>
        $.when(collection.getNextPage()).done =>
          store_id = App.routeModels.get('store').get('id')
          collection.collect (content) ->
            products = content.get('tagged-products')
            if products
              products.collect (product) ->
                App.request('fetch:product', store_id, product)
          layout.trigger('fetch:next-page:complete')
    )

    layout.on 'show', ->
      layout.list.show contentList
      layout.listControls.show contentListControls
      layout.multiedit.show multiEditView

    return layout

  ContentList
