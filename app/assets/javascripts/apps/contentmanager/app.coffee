define [
  'app',
  'backboneprojections',
  'marionette',
  'jquery',
  'underscore',
  './views'
  'entities',
  'exports',
  './controller'
  './views/content_list',
  './views/edit_area',
  './views/index_layout',
  './views/list_controls',
  './views/quick_view',
  './views/tagged_inputs',
], (App, BackboneProjections, Marionette, $, _, Views, Entities, ContentManager) ->

  class ContentManager.Router extends Marionette.AppRouter

    appRoutes:
      ":store_id/content": "contentIndex"

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
