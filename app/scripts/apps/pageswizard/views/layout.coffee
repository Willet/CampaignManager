define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateLayout extends Marionette.Layout

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
            { var: "heroImageMobile", label: "Hero Image (Mobile)", type: "image" }
            { var: "legalCopy", label: "Legal Copy", type: "textarea" },
            { var: "facebookShare", label: "Facebook Share Copy", type: "text" },
            { var: "twitterShare", label: "Twitter Share Copy", type: "text" },
            { var: "emailShare", label: "Email Share Copy", type: "text" }
          ]
      _.each jsonFields, (field) =>
        if model_value = @model.get("fields")?[field['var']]
          field['value'] = model_value
      jsonFields

    triggers:
      "click .js-next": "save"

    events:
      "click .layout-type": "selectLayoutType"
      "change .image-field": "updateImgPreview"

    getFields: ->
      results = {}
      _.each $("#layout-field-form textarea"), (m) ->
        results[$(m).attr("for")] = $(m).val() if $(m).attr("for")
      _.each $("#layout-field-form input[type!=file]"), (m) ->
        results[$(m).attr("for")] = $(m).val() if $(m).attr("for")
      results

    updateImgPreview: (event) ->
      #Get input element
      elem = event.currentTarget
      unless /.(jpg|jpeg|png)/.test($(elem).val())
        console.error "Invalid file selected (not an image)."

      #Scans through json field objects and, using the "for"
      #attribute as an indentifier, finds the related object
      targetField = null
      for field in @getLayoutJSON()
        if field.var is elem.getAttribute("for")
          targetField = field

      fileReader = new FileReader()
      fileReader.onload = (event) =>
        #Updates related json object and refreshes view

        # targetField does not exist usually
        #targetField.url = event.target.result
        filename = elem.files[0].name

        data = new FormData()
        data.append('file', elem.files[0])

        # Post file
        $.ajax(
            url: 'http://contentgraph-test.elasticbeanstalk.com/graph/store/38/page/97/files/' + filename
            type: 'POST'
            data: data
            cache: false
            contentType: false
            processData: false
        )

        @$(elem).next().attr('src', event.target.result)

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
      new_layout = @extractClassSuffix(@$(event.currentTarget), 'js-layout')
      @model.set('layout', new_layout)
      @render()

    initialize: (opts) ->
      @listenTo(@model, "sync", => @render())

    onRender: (opts) ->
      @stickit()
      @$(".steps .layout").addClass("active")

    onShow: (opts) ->

  Views
