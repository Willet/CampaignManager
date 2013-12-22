define [
  'app',
  '../app',
  './list_view',
  '../views',
  '../edit_content/edit_controller',
  'backbone.projections',
  'components/views/main_layout', 'components/views/main_nav', 'components/views/title_bar',
  'marionette',
  '../edit_content/edit_controller'
], (App, ContentManager, Views, ContentViews, EditController, BackboneProjections, MainLayout, MainNav, Marionette) ->

  class ContentManager.Controller extends App.Controllers.Base

    contentListViewType: Views.ContentGridItem
    filters:  # default filters (type, source, tags, ...)
      'type': ''
      'status': 'needs-review'
      'source': ''

    addFilters: (newFilters={}) ->
      _.extend @filters, newFilters

    setContentListViewType: (viewType) ->
      @contentListViewType = viewType

    # @returns {ContentGridItem}
    getContentListViewType: ->
      @contentListViewType

    # @returns a grid view or a list view, depending on how "this" is configured
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
      selectedCollection = new BackboneProjections.Filtered(contents,
        filter: ((m) -> m.get('selected') is true))

      layout = new Views.ListLayout()

      # swap the current view (whatever it is) with a grid view.
      layout.on 'grid-view', () =>
        @setContentListViewType Views.ContentGridItem
        layout.list.show @getContentList(contents)

      # swap the current view (whatever it is) with a list view.
      layout.on 'list-view', () =>
        @setContentListViewType Views.ContentListItem
        layout.list.show @getContentList(contents)

      layout.on 'change:filter-content-status', (status) =>
        @filters.status = status
        contents.setFilter(@filters)

      layout.on 'change:sort-order', (new_order) -> contents.updateSortOrder(new_order)
      layout.on 'content:select-all', => collection.selectAll()
      layout.on 'content:unselect-all', => collection.unselectAll()
      layout.on 'fetch:next-page', () =>
        contents.getNextPage()
        layout.trigger('fetch:next-page:complete')

      layout.on 'show', =>
        layout.list.show @getContentList(contents)

        listControls = @getContentListControls()
        listControls.on 'change:filter-content-type', (contentType) ->
          contents.setFilter self.addFilters('type': contentType or '')

        listControls.on 'change:filter-content-source', (contentSource) ->
          contents.setFilter self.addFilters('source': contentSource or '')

        listControls.on 'change:filter-content-tags', (contentTags) ->
          console.log contentTags
          # contents.setFilter self.addFilters('tags': contentTags or null)

        layout.listControls.show listControls
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

      contentList.on 'itemview:edit_content',
        (view, args) =>
          content = args.model
          controller = new EditController content

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

      # previews the selected content.
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
