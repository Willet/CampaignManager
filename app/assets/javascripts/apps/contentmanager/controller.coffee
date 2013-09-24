define [
  './app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  './views'
  'entities',
  './views/content_list',
  './views/edit_area',
  './views/index_layout',
  './views/list_controls',
  './views/quick_view',
  './views/tagged_inputs',
], (ContentManager, BackboneProjections, Marionette, $, _, Views, Entities) ->

  class ContentManager.Controller extends Marionette.Controller

    contentIndex: (store_id) ->
      collection = new Entities.ContentPageableCollection()
      selectedCollection = new BackboneProjections.Filtered(collection, filter: ((m) -> m.get('selected') is true))
      collection.store_id = store_id
      $.when(
        collection.getNextPage()
      ).done ->
        @layout = new Views.ContentIndexLayout()

        contentList = new Views.ContentList collection: collection
        contentListControls = new Views.ContentListControls()
        multiEditView = new Views.ContentEditArea model: selectedCollection

        #
        # Actions
        #

        @layout.on "change:sort-order", (new_order) -> collection.updateSortOrder(new_order)

        contentListControls.on "change:state",
          (state) =>
            if state == "grid"
              @layout.multiedit.$el.css("display", "block")
            else
              @layout.multiedit.$el.css("display", "none")
            contentList.render()

        contentList.on "itemview:content:approve",
          (view, args) => args.model.approve()

        contentList.on "itemview:content:reject",
          (view, args)  => args.model.reject()

        contentList.on "itemview:content:undecided",
          (view, args)  => args.model.undecided()

        contentList.on "itemview:edit:tagged-products:add",
          (view, editArea, tagger, product) ->
            view.model.get('tagged-products').add(product)
            view.model.save(silent: true)

        contentList.on "itemview:edit:tagged-products:remove",
          (view, editArea, tagger, product) ->
            view.model.get('tagged-products').remove(product)
            view.model.save(silent: true)

        contentList.on "itemview:content:select-toggle",
          (view, args)  =>
            model = args.model
            model.set("selected", !model.get("selected"))

        contentList.on "itemview:content:preview",
          (view, args) => App.modal.show new Views.ContentQuickView model: args.model

        multiEditView.on "content:approve",
          (args)  => args.model.collect((m) -> m.approve())

        multiEditView.on "content:reject",
          (args)  => args.model.collect((m) -> m.reject())

        multiEditView.on "content:undecided",
          (args)  => args.model.collect((m) -> m.undecided())

        tagData = new TagData(collection)
        pIdUnion = new FrequencyList()

        selectedCollection.on "add", (model) ->
          added = pIdUnion.addList model.get("tagged-products").map((m) -> m.get('id'))
          _.each added,
            (product_id) ->
              multiEditView.addProduct(model.get("tagged-products").get(product_id))

        selectedCollection.on "remove", (model) ->
          removed = pIdUnion.removeList model.get("tagged-products").map((m) -> m.get('id'))
          _.each removed,
            (product_id) ->
              multiEditView.removeProduct(model.get("tagged-products").get(product_id))

        @layout.on("content:select-all", => collection.selectAll())

        @layout.on("content:unselect-all", => collection.unselectAll())

        @layout.on("fetch:next-page", => collection.getNextPage())

        #
        # Show
        #

        @layout.on "show", =>
          @layout.list.show contentList
          @layout.listControls.show contentListControls
          @layout.multiedit.show multiEditView

        App.show @layout
        App.setTitle "Content"

  ContentManager