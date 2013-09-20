define [
  'app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  'views/contentmanager',
  'entities',
  'entities/base'
], (App, BackboneProjections, Marionette, $, _, Views, Entities, Base) ->

  ContentManager = App.module("ContentManager")

  class ContentManager.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/content": "contentIndex"

  class ContentManager.Controller extends Marionette.Controller

    contentIndex: (store_id) ->
      collection = new Entities.ContentPageableCollection()
      selectedCollection = new BackboneProjections.Filtered(collection, filter: ((m) -> m.get('selected') is true))
      collection.store_id = store_id
      $.when(
        collection.getNextPage()
      ).done(->
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

      )

  #Data object to hold content tag data in terms of ids
  #The idea is that there is one big ajax request when the page loads from which the minimal Id data is stored locally
  #and from there on ajax requests are only made when non-id data needs to be displayed
  class TagData
    constructor: (collection) ->
      #Arrays are kept in sync, so taggestProducts[idx] = products for contentIds[idx]
      @contentIds = [] #Sorted
      @taggedProducts = []
      @taggedPages = []

      collection.each (m) =>
        @addContent m.get('id')

    addContent: (contId) =>
      #Inserts into sorted array, smallest first
      idx = @insertIntoSortedArray(@contentIds,contId)
      @taggedProducts.splice(idx,0,[])
      @taggedPages.splice(idx,0,[])

    tagWithProduct: (contId, prodId) =>
      @insertIntoSortedArray(@getTaggedProductIdsFor(contId), prodId)

    untagWithProduct: (contId, prodId) =>
      a = @getTaggedProductIdsFor(contId)
      a.splice(@getIdx(a,prodId),1)

    tagWithPage: (contId, pageId) =>
      @insertIntoSortedArray(@getTaggedPageIdsFor(contId), pageId)

    untagWithPage: (contId, pageId) =>
      a = @getTaggedPageIdsFor(contId)
      a.splice(@getIdx(a,pageId),1)

    getTaggedProductIdsFor: (contId) =>
      r = @taggedProducts[@getIdx(@contentIds,contId)]
      return r

    getTaggedPageIdsFor: (contId) =>
      r = @taggedPages[@getIdx(@contentIds,contId)]
      return r

    # Helper functions #

    #For arrays sorted smallest elements first
    #Returns index of inserted item
    insertIntoSortedArray: (a, num) ->
      idx = 0
      while idx < a.length
        if a[idx] > num
          break
        idx = idx + 1
      a.splice(idx,0,num)
      return idx

    #Returns index of element, using binary search
    getIdx: (a, num) ->
      low = 0
      high = a.length - 1
      while high > low
        mid = Math.round((high-low)/2) + low
        if a[mid] is num
          return mid
        else
          if a[mid] > num
            high = mid - 1
          else
            low = mid + 1
      if a[low] is num
        return low

      #Element not found
      return -1

  #Works like a list, expect for duplicates in the item list there is an
  #associated list specifying how many duplicates there are of each item
  class FrequencyList
    constructor: ->
      @items = []
      @freq = []

    #Returns list of items that were added to the items list
    addList: (list) ->
      added = []
      for item in list
        if @addItem(item) then added.push(item)
      return added

    #Returns list of items that were removed from the items list
    removeList: (list) ->
      removed = []
      for item in list
        if @removeItem(item) then removed.push(item)
      return removed

    #Returns True if item does not already exist in list
    addItem: (item) ->
      idx = @items.indexOf(item)
      if idx is -1
        @items.push(item)
        @freq.push(1)
        true
      else
        @freq[idx] = @freq[idx] + 1
        false

    #Returns True if item will not exist in list after operation
    removeItem: (item) ->
      idx = @items.indexOf(item)
      if idx is -1
        console.log("Error: PId to remove is not in set")
        return false
      @freq[idx] = @freq[idx] - 1
      if @freq[idx] is 0
        @items.splice(idx,1)
        @freq.splice(idx,1)
        true
      else
        false

  App.addInitializer ->
    controller = new ContentManager.Controller()
    router = new ContentManager.Router(controller: controller)

  return ContentManager
