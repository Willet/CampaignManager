
define [
  'app',
  '../app',
  './content_view'
], (App, PageManager, Views) ->

  PageManager.Content ?= {}

  class PageManager.Content.Controller extends App.Controllers.Base

    contentListViewType: Views.PageCreateContentGridItem

    setContentListViewType: (viewType) ->
      @contentListViewType = viewType

    getContentListViewType: ->
      @contentListViewType

    getContentListView: (contents) ->
      new Views.PageCreateContentList
        collection: contents
        itemView: @getContentListViewType()

    initialize: ->
      page = App.routeModels.get 'page'
      store = App.routeModels.get 'store'
      contents = App.request 'content:all', store

      layout = new Views.PageCreateContent
        model: page

      layout.on 'grid-view', () =>
        @setContentListViewType Views.PageCreateContentGridItem
        layout.contentList.show @getContentListView(contents)

      layout.on 'list-view', () =>
        @setContentListViewType Views.PageCreateContentListItem
        layout.contentList.show @getContentListView(contents)

      # Item View Actions
      layout.on 'content_list:itemview:add_content', (listView, itemView) ->
        content = itemView.model
        App.request 'page:add_content', page, content

      layout.on 'content_list:itemview:remove_content', (listView, itemView) ->
        content = itemView.model
        App.request 'page:remove_content', page, content

      layout.on 'content_list:itemview:prioritize_content', (listView, itemView) ->
        content = itemView.model
        App.request 'page:prioritize_content', page, content

      layout.on 'content_list:itemview:preview_content', (listView, itemView) ->
        content = itemView.model
        App.modal.show new Views.PageCreateContentPreview({model: content})

      # Displayed Content
      layout.on 'change:filter', () ->
        filter = layout.extractFilter()
        contents.setFilter(filter)

      layout.on 'select-all', () =>
        contents.collect((model) -> model.set('selected', true))
        layout.contentList.show @getContentListView(contents)

      layout.on 'select-none', () =>
        contents.collect((model) -> model.set('selected', false))
        layout.contentList.show @getContentListView(contents)

      layout.on 'add-selected', () =>
        selected = contents.filter((model) -> model.get('selected'))
        _.each selected, (model) ->
          App.request 'page:add_content', page, model
          model.set 'selected', false
        layout.contentList.show @getContentListView(contents)

      layout.on 'remove-selected', () =>
        selected = contents.filter((model) -> return model.get('selected'))
        _.each selected, (model) ->
          App.request 'page:remove_content', page, model
          model.set 'selected', false
        layout.contentList.show @getContentListView(contents)

      layout.on 'display:all-content', () =>
        contents = App.request 'store:content', store, layout.extractFilter()
        layout.contentList.show @getContentListView(contents)

      layout.on 'display:suggested-content', () =>
        contents = App.request 'page:content', page, layout.extractFilter()
        layout.contentList.show @getContentListView(contents)

      layout.on 'display:added-content', () =>
        contents = App.request 'page:content', page, layout.extractFilter()
        layout.contentList.show @getContentListView(contents)

      @listenTo layout, 'show', =>
        layout.contentList.show @getContentListView(contents)

      layout.on 'fetch:next-page', () ->
        contents.getNextPage()

      layout.on 'save', () ->
        $.when(page.save()).done (data) ->
          App.navigate('/' + store.get('id') + '/pages/' + page.get('id') + '/publish', { trigger: true })

      @show layout
