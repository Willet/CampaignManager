define [
  "marionette",
  "jquery",
  "entities/base"
  "select2"
], (Marionette, $, Base) ->

  ContentActions =

    undecideContent: (event) ->
      @model.undecided()
      event.stopPropagation()
      false

    approveContent: (event) ->
      @model.approve()
      event.stopPropagation()
      false

    rejectContent: (event) ->
      @model.reject()
      event.stopPropagation()
      false

    prioritizeContent: (event) ->
      alert("TODO: prioritize items")
      event.stopPropagation()
      false

  class GridItem extends Marionette.Layout

    template: "_content_grid_item"

    regions:
      "editArea": ".edit-area"

    events:
      "click .overlay": "selectItem"
      "click .js-view": "viewModal"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "click .js-undecided": "undecideContent"
      "click .js-prioritize": "prioritizeContent"
      "click .js-select": "toggleSelected"
      "click a": "stopPropagation"

    initialize: ->
      _.extend(@, ContentActions)
      @model.on("change", => @render())

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    serializeData: -> @model.viewJSON()

    viewModal: (event) ->
      # TODO: soft navigation ? without losing selection
      require("app").modal.show(new QuickView(model: @model))
      event.stopPropagation()
      false

    selectItem: (event) ->
      @model.set('selected', !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    stopPropagation: (event) ->
      event.stopPropagation()
      false

    onRender: ->
      @editArea.show(new EditArea(model: @model, pages: new Base.Collection()))

    class QuickView extends Marionette.ItemView

      template: "_content_quick_view"

      serializeData: -> @model.viewJSON()

  class EditArea extends Marionette.Layout

    template: "_content_edit_item"

    serializeData: -> @model.viewJSON()

    events:
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"
      "select2-blur .js-tagged-products": "productsChanged"
      "select2-blur .js-tagged-pages": "pagesChanged"

    initialize: (options) ->
      _.extend(@, ContentActions)
      @pages = options['pages']

    productsChanged: (event) ->
      @trigger("change:tagged-products", @$(".js-tagged-products").select2("data"))

    pagesChanged: (event) ->
      @trigger("change:tagged-pages", @$(".js-tagged-pages").select2("data"))

    setupTaggedProducts: ->
      ## TODO: should build select2 component view
      @$('.js-tagged-products').select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{require("app").apiRoot}/stores/#{@model.get("store-id")}/products"
          dataType: 'json'
          cache: true
          data: (term, page) ->
            return {
              "name-prefix": term
            }
          results: (data, page) ->
            return {
              results: data['products']
            }
        formatResult: (product) ->
          "<span>#{product['name']}</span>"
        formatSelection: (product) ->
          "<span>#{product['name']} #{product['id']}</span>"
      )
      false

    setupTaggedPages: ->
      ## TODO: should build select2 component view
      @$('.js-tagged-pages').select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a page"
        tokenSeparators: [',']
        data:
          results: @pages.toJSON()
          text: (item) -> item['name']
        formatNoMatches: (term) ->
          "No pages match '#{term}'"
        formatResult: (campaign) ->
          "<span>#{campaign['name']}</span>"
        formatSelection: (campaign) ->
          "<span>#{campaign['name']} #{campaign['id']}</span>"
      )

    onShow: ->
      @on("change:tagged-products", (data) -> console.log data)
      @setupTaggedProducts()
      @setupTaggedPages()

    onClose: ->
      @$('.js-tagged-products').select2('destroy')

  class ContentList extends Marionette.CollectionView

    getItemView: (item) ->
      GridItem

  class Index extends Marionette.Layout
    
    id: 'content-index'

    className: "grid-view"

    template: "content_index"

    regions:
      "itemRegion": "#items"
      "editArea": ".edit-area"

    events:
      "click .js-select-all": "selectAll"
      "click .js-unselect-all": "unselectAll"
      "click dd": "updateActive"
      "click .js-next-page": "nextPage"
      "change #sort-order": "updateSortOrder"
      "change #filter-page": "filterPage"
      "change #filter-content-type": "filterContentType"

    last_id: null

    filterContentType: (event) ->
      @trigger("change:filter-content-type", @$(event.currentTarget).val())

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    updateSortOrder: (event) ->
      @trigger("change:sort-order", @$(event.currentTarget).val())

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    nextPage: ->
      $.when(
        @model.getNextPage()
      ).done(=>
        @trigger("nextpage")
      )
      false

    updateActive: (event) ->
      @switchActive(@extractState(event.currentTarget))

    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    currentlyActive: ->
      @$('.tabs dd.active').className.split(/\s+/)

    switchActive: (new_state) ->
      @$(".tabs .active").removeClass("active")
      @$(".tabs .js-tab-#{new_state}").addClass("active")
      @current_state = new_state
      @$el.removeClass("grid-view").removeClass("list-view").addClass("#{new_state}-view")
      @itemRegion.currentView.render()

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      @current_state = opts['inital_state']
      @contentListView = new ContentList(
        collection: @model
      )
      @editView = new EditArea(model: new Base.Model(), pages: new Base.Collection())

    unselectAll: ->
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: false)))
      removed =  @pIdUnion.items
      for item in removed
        @removeProductFromTxtBox(item)
      @pIdUnion.init()
      @selectedItems = []
      @selDataChange()

    selectAll: ->
      # TODO: this is a hack
      objs = _.clone(@model.models)
      _.each(objs, (m) -> _.defer(=> m.set(selected: true)))

      added = []
      for item in objs
        unless item in @selectedItems
          added = added.concat(@pIdUnion.addList(@tagData.getTaggedProductIdsFor(item.get('id'))))

      #Updates txt box display
      for item in added
        @addProductToTxtBox(item,126)

      @selectedItems = objs
      @selDataChange()

    onRender: (opts) ->
      @itemRegion.show(@contentListView)
      @editArea.show(@editView)
      #@$('#js-tag-search').tokenInput()

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)

      @initSelectionData()
      @initTagData(126)
      @model.on("grid-item:selected", @itemWasSelected)
      @model.on("grid-item:deselected", @itemWasDeselected)

    onClose: ->
      $(window).off("scroll", @scrollFunction)

    initSelectionData: =>
      @selectedItems = []
      @pIdUnion = new FrequencyList()
      @pIdUnion.init()
      objs = @model.models
      _.each(objs, (m) =>
        if m.get("selected") then @itemWasSelected(m)
        )

      @selDataChange()

    itemWasSelected: (m) =>
      #For debugging
      if m in @selectedItems
        console.log("Error: Object is already in selected list")
        return
      @selectedItems.push(m)
      added = @pIdUnion.addList(@tagData.getTaggedProductIdsFor(m.get('id')))

      #Updates txt box display
      for item in added
        @addProductToTxtBox(item,126)

      @selDataChange()

    itemWasDeselected: (m) =>
      #For debugging
      unless m in @selectedItems
        console.log("Error: Object isn't in selected list")
        return
      @selectedItems.splice(@selectedItems.indexOf(m),1)
      removed = @pIdUnion.removeList(@tagData.getTaggedProductIdsFor(m.get('id')))

      #Updates txt box display
      for item in removed
        @removeProductFromTxtBox(item)

      @selDataChange()

    selDataChange: =>
      #For debugging
      #@selDataPrint()

    selDataPrint: =>
      console.log("=== Selected Item Ids ===")
      ids = (m.get('id') for m in @selectedItems)
      console.log(ids)

      ids = @pIdUnion.items
      console.log("== Tagged Product Ids ==")
      console.log(ids)
      #for id in ids
      #  @addProductToTxtBox(id,126)

    addProductToTxtBox: (pId,storeId) =>
      $.ajax "#{require("app").apiRoot}/stores/#{storeId}/products/#{pId}",
        type: 'GET'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log("AJAX Error while adding product to textbox: #{textStatus}")
        success: (data, textStatus, jqXHR) ->
            dataArray = $('div#selection-edit .js-tagged-products').select2("data")
            dataArray.push(data)
            $('div#selection-edit .js-tagged-products').select2("data",dataArray)

    removeProductFromTxtBox: (pId) =>
      dataArray = @$('div#selection-edit .js-tagged-products').select2("data")
      idx = 0
      while idx < dataArray.length
        if dataArray[idx]["id"] is pId
          dataArray.splice(idx,1)
          break
        idx = idx + 1
      @$('div#selection-edit .js-tagged-products').select2("data",dataArray)

    initTagData: (storeId) =>
      @tagData = new TagData()
      @tagData.init()
      $.ajax "#{require("app").apiRoot}/stores/#{storeId}/content",
        type: 'GET'
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
            console.log("AJAX Error while initializing tag data: #{textStatus}")
        success: (data, textStatus, jqXHR) =>
            #Adds Content Id Data
            size = data["size"]
            products = data["content"]
            i = 0
            while i < size
              p = products[i]
              @tagData.addContent(p["id"])
              i = i + 1

            #Adds content tag data
            #TODO: This data currently does not exist yet, so I am just using some placeholders
            @tagData.tagWithProduct(172,46)
            @tagData.tagWithProduct(172,47)
            @tagData.tagWithProduct(173,46)
            @tagData.tagWithProduct(173,47)
            @tagData.tagWithProduct(173,49)
            @tagData.tagWithProduct(174,47)
            @tagData.tagWithProduct(174,49)

    #Data object to hold content tag data in terms of ids
    #The idea is that there is one big ajax request when the page loads from which the minimal Id data is stored locally
    #and from there on ajax requests are only made when non-id data needs to be displayed
    class TagData
      init: =>
        #Arrays are kept in sync, so taggestProducts[idx] = products for contentIds[idx]
        @contentIds = [] #Sorted
        @taggedProducts = []
        @taggedPages = []

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
      init: =>
        @items = []
        @freq = []

      #Returns list of items that were added to the items list
      addList: (list) =>
        added = []
        for item in list
          if @addItem(item) then added.push(item)
        return added

      #Returns list of items that were removed from the items list
      removeList: (list) =>
        removed = []
        for item in list
          if @removeItem(item) then removed.push(item)
        return removed

      #Returns True if item does not already exist in list
      addItem: (item) =>
        idx = @items.indexOf(item)
        if idx is -1
          @items.push(item)
          @freq.push(1)
          true
        else
          @freq[idx] = @freq[idx] + 1
          false

      #Returns True if item will not exist in list after operation
      removeItem: (item) =>
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

  class ViewModeSelect extends Marionette.ItemView

    template: "_view_mode_select"

    events:
      "click dd": "updateActive"

    initialize: (opts) ->
      @current_state = opts['inital_state']

    updateActive: (event) ->
      @switchActive(@extractState(event.currentTarget))

    extractState: (element) ->
      if result = element.className.match(/js-tab-([a-zA-Z-_]+)/)
        return result[1]
      null

    currentlyActive: ->
      @$('.tabs dd.active').className.split(/\s+/)

    switchActive: (new_state) ->
      @$(".tabs .active").removeClass("active")
      @$(".tabs .js-tab-#{new_state}").addClass("active")
      @current_state = new_state
      @trigger('new-state', @current_state)

  class Show extends Marionette.Layout

    template: "content_show"

    events:
      "click .js-save": "saveContent"
      "click .js-approve": "approveContent"
      "click .js-reject": "rejectContent"

    serializeData: -> @model.viewJSON()

    initialize: (opts) ->
      _.extend(@, ContentActions)

    onRender: (opts) ->

    onShow: (opts) ->

    saveContent: (event) ->
      data = @$('form').serializeObject()
      @model.save(data)
      false

  return {
    Index: Index
    Show: Show
  }


