define [
  'app',
  '../views',
  'jquery',
  'underscore'
], (App, Views, $, _) ->
  class Views.EditContentLayout extends App.Views.Layout
    template: 'content/edit/index'

    regions:
      taggedProducts: '.tagged-products'
      addTaggedProducts: '.tag-content'

    triggers:
      'click .reveal-close .reveal-modal-bg' : 'closeEditView'

    serializeData: -> @model.viewJSON()

    initialize: ->
      @storeId = App.routeModels.get('store').id


    # Move this block to a separate file maybe
    onShow: ->

      formatProduct = (product) =>
        unless product instanceof Backbone.Model
          product = new Entities.Product($.extend(product, {'store-id': @storeId}))
        imageUrl = product.viewJSON()['default-image']?.images?.thumb.url || null
        identifier = "product-#{product.get('id')}"

        # replace image url when model is fetched if it wasn't ready when we rendered
        if imageUrl == null
          imageUrl = 'http://placehold.it/20/eee/000&text=X'
          # Yes, this is a horrible idea. However, we don't have a CID as the model
          # has not been fetched yet, and I can't think of a better way. Needless to
          # say, feel free to modify if you can think of something less idiotic.
          intv = setInterval(() ->
            if (imageUrl = product.viewJSON()['default-image']?.images?.thumb.url || null)

              $(".#{identifier} img").attr('src', imageUrl)
              clearInterval intv
          , 1000)

        image = "<img src=\"#{imageUrl}\">"
        name = "<span>#{product.get("name")}</span>"
        "<span class=\"#{identifier}\">#{image} #{name}</span>"

      $caption = $('textarea.tag-content-caption')
      $caption.on "keyup", _.debounce(((event) =>
        caption = $(event.currentTarget).val()
        @saveModel = true
        @model.set('caption', caption)
      ), 1000)

      $el = $('.tag-content')
      $el.select2(
        multiple: true
        width: '350px'
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
      $el.select2('data', @model.get('tagged-products').models)
      $el.on "change", (event, element) =>

        @saveModel = true
        if event.added
          unless event.added instanceof Entities.Product
            product = new Entities.Product $.extend(event.added,
              'store-id': @storeId
            )
          @model.get('tagged-products').add(id: product.get('id'));

        else if event.removed
          removedId = event.removed.id

          @model.get('tagged-products').remove(removedId);

    onClose: =>
      if @saveModel
        @model.save();

      $('.tag-products').select2('destroy')

  Views
