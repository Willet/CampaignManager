define [
  "marionette",
  "../views",
  "backbone.stickit"
], (Marionette, Views) ->

  class Views.PageCreateName extends Marionette.Layout

    template: "pages_name"

    serializeData: ->
      return {
        page: @model.toJSON()
        "store-id": @model.get("store-id")
        "title": @model.get("name")
      }

    triggers:
      "click .js-next": "save"

    bindings:
      'input[for=name]':
        observe: 'name'
        events: ['blur']
      'input[for=url]':
        observe: 'url'
        events: ['blur']

    initialize: (opts) ->

    onRender: (opts) ->
      @backbone.stickit()
      @$(".steps .main").addClass("active")

    onShow: (opts) ->

  Views