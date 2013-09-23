define [
  "marionette",
  "../views",
  "stickit"
], (Marionette, Views) ->

  class Views.PageCreateLayout extends Marionette.Layout

    template: "pages_layout"

    jsonFields: [
          { var: "heroImageMobile", label: "Hero Image (Mobile)", type: "image" }
          { var: "legalCopy", label: "Legal Copy", type: "textarea" },
          { var: "facebookShare", label: "Facebook Share Copy", type: "text" },
          { var: "twitterShare", label: "Twitter Share Copy", type: "text" },
          { var: "emailShare", label: "Email Share Copy", type: "text" }
        ]
    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
        fields: @jsonFields
      }

    triggers:
      "click .js-next": "save"

    events:
      "click .layout-type": "selectLayoutType"
      "change .image-field": "updateImgPreview"

    updateImgPreview: (event) ->
      #Get input element
      elem = event.currentTarget

      #Scans through json field objects and, using the "for"
      #attribute as an indentifier, finds the related object
      targetField = null
      for field in @jsonFields
        if field.var is elem.getAttribute("for")
          targetField = field

      fileReader = new FileReader()
      fileReader.onload = (event) =>
        #Updates related json object and refreshes view
        targetField.loadedUrl = event.target.result
        @render()

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
      @$('#layout-types .layout-type').removeClass('selected')
      layoutClicked.addClass('selected')
      new_layout = @extractClassSuffix(@$(event.currentTarget), 'js-layout')
      @trigger 'layout:selected', new_layout
      @model.set('layout', new_layout)

    initialize: (opts) ->

    onRender: (opts) ->
      @stickit()
      @$(".steps .layout").addClass("active")

    onShow: (opts) ->

  Views