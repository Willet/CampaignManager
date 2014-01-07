define [
  'app',
  '../views',
  'backbone.stickit'
], (App, Views) ->

  class Views.PageCreateLayout extends App.Views.Layout

    template: "page/layout"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
        fields: @getLayoutJSON()
      }

    getLayoutJSON: ->
      jsonFields = [
            { var: "heroImageDesktop", label: "Hero Image (Desktop)", type: "image" },
            { var: "heroImageMobile", label: "Hero Image (Mobile)", type: "image" },
            { var: "legalCopy", label: "Legal Copy", type: "textarea" },
            { var: "shareText", label: "Share Text", type: "text" },
          ]
      _.each jsonFields, (field) =>
        field.value = @model.get(field.var)
      jsonFields

    triggers:
      "click .js-next": "save"

    events:
      "click .layout-type": "selectLayoutType"
      "change .image-field": "updateImgPreview"

    getFields: ->
      results = {}
      _.each $("#layout-field-form textarea"), (m) ->
        results[$(m).attr("name")] = $(m).val() if $(m).attr("name")
      _.each $("#layout-field-form input[type!=file]"), (m) ->
        results[$(m).attr("name")] = $(m).val() if $(m).attr("name")
      _.each $("#layout-field-form input[type=file]"), (m) ->
        results[$(m).attr("name")] = $(m).attr('value') if $(m).attr("name")
      results

    updateImgPreview: (event) ->
      #Get input element
      self = @
      elem = event.currentTarget
      unless /.(jpg|jpeg|png)/.test($(elem).val())
        console.error "Invalid file selected (not an image)."

      #Scans through json field objects and, using the "name"
      #attribute as an indentifier, finds the related object
      targetField = null
      for field in @getLayoutJSON()
        if field.var is elem.getAttribute("name")
          targetField = field

      fileReader = new FileReader()
      fileReader.onload = (event) =>
        #Updates related json object and refreshes view
        filename = elem.files[0].name

        data = new FormData()
        data.append('file', elem.files[0])

        # Post file
        # TODO: Can't use proxy; how to avoid hardcoding URL?
        $.ajax(
            url: 'http://contentgraph-test.elasticbeanstalk.com/graph/store/38/page/97/files/' + filename
            type: 'POST'
            data: data
            cache: false
            contentType: false
            dataType: 'json'
            processData: false,
            success: (data) ->
              targetField.url = data.url
              self.$(elem).attr('value', data.url)
              self.$('img[alt="' + self.$(elem).attr('name') + '"]')
                .attr('src', data.url)
        )

      fileReader.readAsDataURL(elem.files[0])

    bindings:
      '.js-layout-hero':
        attributes: [
          {
            name: 'class'
            observe: 'layout'
            onGet: (val, options) ->
              if val == "hero" then "selected" else ""
          }
        ],
      '.js-layout-featured':
        attributes: [
          {
            name: 'class'
            observe: 'layout'
            onGet: (val, options) ->
              if val == "featured" then "selected" else ""
          }
        ],
      '.js-layout-shopthelook':
        attributes: [
          {
            name: 'class'
            observe: 'layout'
            onGet: (val, options) ->
              if val == "shopthelook" then "selected" else ""
          }
        ]

    selectLayoutType: (event) ->
      layoutClicked = @$(event.currentTarget)
      return if layoutClicked.hasClass('disabled')
      new_layout = @extractClassSuffix(@$(event.currentTarget), 'js-layout')
      @model.set('layout', new_layout)
      @render()

    initialize: (opts) ->
      @listenTo(@model, "sync", => @render())

    onRender: (opts) ->
      @stickit()

    onShow: (opts) ->

  Views
