define [
  'app',
  '../app',
  '../views',
  'entities'
], (App, ContentManager, Views, Entities) ->

  class Views.ListLayout extends App.Views.Layout

    template: 'content/index'

    regions:
      "list": ".content-list-region"
      "listControls": "#list-controls"
      "multiedit": ".edit-area"
      "loading": ".content-list-loading-region"

    events:
      "click dd": "updateActive"
      "change #js-filter-page": "filterPage"
      "click .js-filter-content-status": "filterContentStatus"

    toggleSelected: (event) ->
      @model.set(selected: !@model.get('selected'))
      if @model.get('selected')
        @model.trigger("grid-item:selected",@model)
      else
        @model.trigger("grid-item:deselected",@model)

    triggers:
      "click .js-grid-view": "grid-view"
      "click .js-list-view": "list-view"
      "click .js-select-all": "content:select-all"
      "click .js-unselect-all": "content:unselect-all"

    initialize: (opts) ->
      @current_state = opts['initial_state']
      @status = ''

    # event triggered when all/needs review/approved/rejected tabs are clicked
    filterContentStatus: (event) ->
      @status = @$(event.currentTarget).val()
      @trigger("change:filter-content-status", @status)

    filterPage: (event) ->
      @trigger("change:filter-page", @$(event.currentTarget).val())

    autoLoadNextPage: (event) ->
      distanceToBottom = 75
      if ($(document).scrollTop() + $(window).height()) > $(document).height() - distanceToBottom
        @nextPage()

    nextPage: ->
      @$('.loading').show()
      @trigger("fetch:next-page")
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
      @$('#list').removeClass("grid-view").removeClass("list-view").addClass("#{new_state}-view")

    onRender: (opts) ->

    onShow: (opts) ->
      @scrollFunction = => @autoLoadNextPage()
      $(window).on("scroll", @scrollFunction)
      @$('.loading').hide()

      @on "fetch:next-page:complete", =>
        @$('.loading').hide()

    onClose: ->
      $(window).off("scroll", @scrollFunction)

  class Views.ContentLoadingContent extends App.Views.ItemLoadingView

    template: "shared/items/loading"
    emptyTemplate: "shared/items/empty"
    completeTemplate: "shared/items/complete"

  class Views.ContentListControls extends App.Views.ItemView

    template: "content/filter_controls"

    events:
      "click dd": "updateActive"
      "keyup #js-filter-content-tags": "onTagsChange"
      "change #js-filter-content-type": "changeFilter"
      "change #js-filter-content-source": "changeFilter"
      "change #js-filter-sort-order": "changeFilter"

    initialize: (opts) ->
      @current_state = "grid"

    onTagsChange: _.debounce (() ->
      @changeFilter()), 1000

    changeFilter: () ->
      filter = {}
      filter['is-content'] = 'true'
      filter['type'] = @$('#js-filter-content-type').val()
      filter['source'] = @$('#js-filter-content-source').val()
      filter['tagged-products'] = @$('#js-filter-content-tags').val()

      # differentiate two kinds of UI "sort by": import/post dates,
      # only one of which can be used to sort the list at any given time
      sortKey = @$('#js-filter-sort-order').val()
      sortDirection = @$('#js-filter-sort-order option:selected').data('direction')
      @$('#js-filter-sort-order option').each () ->
        key = $(this).val()
        filter[key] = ''
      filter[sortKey] = sortDirection

      @trigger("change:filter", filter)

    resetFilter: () ->
      @$('#js-filter-content-type').val('')
      @$('#js-filter-content-source').val('')
      @$('#js-filter-content-tags').val('')
      @$('#js-filter-sort-order [value="order"][data-direction="descending"]').prop('selected', true)

      # Signify that the filter has changed
      @changeFilter()

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
      @trigger('change:state', @current_state)

  class Views.ContentPreview extends App.Views.ItemView

    template: "content/item_preview"

    serializeData: -> @model.viewJSON()

  class Views.TaggedProductInput extends App.Views.ItemView

    initialize: (options) ->
      @store = options['store']
      @storeId = options['store_id'] || App.routeModels.get('store').id
      @autosave = options['autosave'] || false
      @selectTarget = options['selectTarget'] || '.tag-content'
      @captionTarget = options['captionTarget'] || '.content-caption'
      _.bindAll(@, 'onCaptionChange')

    initSelect: (target) ->
      # BUG: If this is a part of a multi-edit, there will be a problem with
      # accessing store / page
      formatProduct = (product) =>
        unless product instanceof Backbone.Model
          product = new Entities.Product($.extend(product, {'store-id': @storeId}))
        imageUrl = product.viewJSON()['default-image']?.images?.thumb.url || 'http://placehold.it/20/eee/000&ext=X'
        identifier = "product-#{product.get('id')}"
        productName = product.viewJSON()['name'] || ''

        # TODO: find a better way to do this
        # We should not be doing this, as with significant amount of products and scrolling occuring
        # at the same time, the user may notice latency.
        limit = 10
        intv = setInterval((() ->
          # while the image/name are still loading, attempt every second
          # to see if we've got them; limit ourselves to ten tries.
          imageUrl = product.viewJSON()['default-image']?.images?.thumb.url
          productName = product.viewJSON()['name']
          # If they're loaded, plug in the values
          if imageUrl
            $(".#{identifier} img").attr('src', imageUrl)
          if productName
            $(".#{identifier} span").text(productName)
          if (productName and imageUrl) || limit == 0
            clearInterval intv
          limit -= 1
        ), 1000)

        image = "<img src=\"#{imageUrl}\">"
        name = "<span>#{productName}</span>"
        "<span class=\"#{identifier}\">#{image} #{name}</span>"

      # Initialize the select2 script on our target that will display
      # the tagged products.
      target.select2(
        multiple: true
        allowClear: true
        placeholder: "Search for a product"
        tokenSeparators: [',']
        ajax:
          url: "#{App.API_ROOT}/store/#{@storeId}/product/live"
          dataType: 'json'
          cache: true
          data: (term, page) ->
            return {
              "search-name": term
            }
          results: (data, page) ->
            return {
              results: data['results']
            }
        formatResult: formatProduct
        formatSelection: formatProduct
      )

      target.select2('data', @model.get('tagged-products').models)
      target.on "change", (event, element) =>
        @saveModel = true
        if event.added
          product = event.added
          unless product instanceof Entities.Product
            product = new Entities.Product $.extend(event.added,
              'store-id': @storeId
            )
          @model.get('tagged-products').add(id: product.get('id'))

        else if event.removed
          productId = event.removed.id
          @model.get('tagged-products').remove(productId)

        if @autosave
          @model.save()

    serializeData: ->
      @model.viewJSON()

    toggleSave: (model) ->
      @saveModel = true
      if @autosave
        @model.save()

    onCaptionChange: _.debounce(
      (() ->
        caption = @$(@captionTarget).val()
        @model.set('caption', caption)
        @saveModel = true
        if @autosave
          @model.save()
      ), 1000)


    onRender: ->
      target = @$(@selectTarget)
      # Need to destroy the select2 instance in the event that it already
      # exists when we're rerendering
      target.select2('destroy')
      @initSelect(target)

    onClose: ->
      # Don't save if we're already autosaving
      if @saveModel and not @autosave
        @model.save()
      @$('.tag-content').select2("destroy")

  class Views.ContentList extends App.Views.CollectionView

    template: false
    tagName: "ul"
    className: "content-list"

  class Views.ContentListItem extends Views.TaggedProductInput

    tagName: "li"
    className: "content-item list-view"
    template: "content/item_list"

    triggers:
      "click .js-content-select": "content:select-toggle"
      "click .js-content-approve": "approve_content"
      "click .js-content-reject": "reject_content"
      "click .js-content-undecided": "undecide_content"
      "click .js-content-preview": "preview_content"
      "click .js-content-edit": "edit_content"
      "keyup .content-caption": "edit_caption"

    initialize: (opts) ->
      @model.on('change:status', => @render())
      super opts

  class Views.ContentGridItem extends App.Views.ItemView

    tagName: "li"
    className: "content-item grid-view"
    template: "content/item_grid"

    triggers:
      "click .js-content-select": "content:select-toggle"
      "click .js-content-approve": "approve_content"
      "click .js-content-reject": "reject_content"
      "click .js-content-undecided": "undecide_content"
      "click .js-content-preview": "preview_content"
      "click .js-content-edit": "edit_content"
      "click .js-content-approve-edit": "approve_content edit_content"

    bindings:
      '.js-selected':
        attributes: [
          name: 'checked'
          observe: 'selected'
          onGet: (observed) ->
            if observed then true else false
        ]
      '.item':
        attributes: [
          name: 'class'
          observe: 'selected'
          onGet: (observed) ->
            if observed then "selected" else ""
        ]

    initialize: ->
      @model.on('change:status', => @render())

    onRender: ->
      @stickit()

  Views
