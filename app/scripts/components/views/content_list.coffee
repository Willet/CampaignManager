define [
  'exports'
  'backbone.projections',
  'underscore',
  'apps/contentmanager/views'
], (ContentList, BackboneProjections, _, ContentViews) ->

  ContentList.createView = (collection, actions = {}) ->

    layout = new ContentViews.ContentIndexLayout initial_state: 'list'
    selectedCollection = new BackboneProjections.Filtered(collection, filter: ((m) -> m.get('selected') is true))

    contentList = new ContentViews.ContentList { collection: collection, actions: actions }
    contentListControls = new ContentViews.ContentListControls()
    multiEditView = new ContentViews.ContentEditArea model: selectedCollection, actions: actions

    #
    # Actions
    #

    layout.on "change:sort-order", (new_order) -> collection.updateSortOrder(new_order)

    contentListControls.on "change:state",
      (state) =>
        if state == "grid"
          layout.multiedit.$el.css("display", "block")
        else
          layout.multiedit.$el.css("display", "none")

    contentList.on "itemview:content:approve",
      (view, args) =>
          args.model.approve()
          args.view.render()

    contentList.on "itemview:content:reject",
      (view, args)  =>
          args.model.reject()
          args.view.render()

    contentList.on "itemview:content:undecided",
      (view, args)  =>
          args.model.undecided()
          args.view.render()

    contentList.on "itemview:edit:tagged-products:add",
      (view, editArea, tagger, product) ->
        view.model.get('tagged-products').add(product)
        view.model.save()

    contentList.on "itemview:edit:tagged-products:remove",
      (view, editArea, tagger, product) ->
        view.model.get('tagged-products').remove(product)
        view.model.save()

    contentList.on "itemview:content:select-toggle",
      (view, args)  => args.model.set("selected", !args.model.get("selected"))

    contentList.on "itemview:content:preview",
      (view, args) => App.modal.show new ContentViews.ContentQuickView model: args.model

    multiEditView.on "content:approve",
      (args)  =>
       args.model.collect((m) -> m.approve())
       models = _.clone(args.model.models)
       _.each(models, (m) -> m.set('selected', false))

    multiEditView.on "content:reject",
      (args)  =>
       args.model.collect((m) -> m.reject())
       models = _.clone(args.model.models)
       _.each(models, (m) -> m.set('selected', false))

    multiEditView.on "content:undecided",
      (args)  =>
       args.model.collect((m) -> m.undecided())
       models = _.clone(args.model.models)
       _.each(models, (m) -> m.set('selected', false))

    layout.on("content:select-all", => collection.selectAll())
    layout.on("content:unselect-all", => collection.unselectAll())
    layout.on("fetch:next-page", =>
      $.when(collection.getNextPage()).done =>
        layout.trigger("fetch:next-page:complete")
    )

    #
    # Show
    #

    layout.on "show", ->
      layout.list.show contentList
      layout.listControls.show contentListControls
      #layout.multiedit.show multiEditView

    return layout

  ContentList