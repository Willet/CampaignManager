define [
  'app',
  '../app',
  './list_view',
  '../views',
  'backbone.projections',
  'components/views/main_layout', 'components/views/main_nav', 'components/views/title_bar'
], (App, ContentManager, Views, ContentViews, BackboneProjections, MainLayout, MainNav) ->

  class ContentManager.Controller extends App.Controllers.Base

    contentListViewType: Views.ContentGridItem

    setContentListViewType: (viewType) ->
      @contentListViewType = viewType

    getContentListViewType: ->
      @contentListViewType

    getContentListView: (contents) ->
      new Views.ContentList
        collection: contents
        itemView: @getContentListViewType()

    contentIndex: () ->
      # Called everytime page is loaded
      # Similar to 'initialize' method
      store = App.routeModels.get 'store'
      contents = App.request 'content:all', store
      App.execute 'when:fetched', contents, =>
        @show @getContentLayout(contents)

    getContentLayout: (contents) ->

      selectedCollection = new BackboneProjections.Filtered(contents, filter: ((m) -> m.get('selected') is true))

      layout = new Views.ListLayout()

      layout.on 'grid-view', () =>
        @setContentListViewType Views.ContentGridItem
        layout.list.show @getContentList(contents)

      layout.on 'list-view', () =>
        @setContentListViewType Views.ContentListItem
        layout.list.show @getContentList(contents)

      layout.on 'change:sort-order', (new_order) -> contents.updateSortOrder(new_order)
      layout.on 'content:select-all', => collection.selectAll()
      layout.on 'content:unselect-all', => collection.unselectAll()
      layout.on 'fetch:next-page', () =>
          contents.getNextPage()
          layout.trigger('fetch:next-page:complete')

      layout.on 'show', =>
        layout.list.show @getContentList(contents)
        layout.listControls.show @getContentListControls()
        layout.multiedit.show @getMultiEditView(selectedCollection)

      return layout

    getContentList: (contents) ->
      contentList = @getContentListView(contents)
      contentList.on 'itemview:approve_content',
        (view, args) =>
          content = args.model
          App.request('content:approve', content)
          args.view.render()

      contentList.on 'itemview:reject_content',
        (view, args)  =>
          content = args.model
          App.request('content:reject', content)
          args.view.render()

      contentList.on 'itemview:undecide_content',
        (view, args)  =>
          content = args.model
          App.request('content:undecide', content)
          args.view.render()

      # DEFER: NOT USED
      contentList.on 'itemview:edit:tagged-products:add',
        (view, editArea, tagger, product) ->
          view.model.get('tagged-products').add(product)
          view.model.save()

      # DEFER: NOT USED
      contentList.on 'itemview:edit:tagged-products:remove',
        (view, editArea, tagger, product) ->
          view.model.get('tagged-products').remove(product)
          view.model.save()

      # DEFER: NOT USED
      contentList.on 'itemview:content:select-toggle',
        (view, args)  =>
          content = args.model
          content.set('selected', !args.model.get('selected'))

      contentList.on 'itemview:preview_content',
        (view, args) =>
          content = args.model
          App.modal.show new Views.ContentPreview(model: content)

    getMultiEditView: (selectedCollection) ->
      multiEditView = new Views.ContentEditArea model: selectedCollection, multiEdit: true

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

      return multiEditView

    getContentListControls: () ->
      contentListControls = new Views.ContentListControls()

  ContentManager
