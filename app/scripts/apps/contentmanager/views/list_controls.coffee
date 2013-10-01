define [
  "marionette",
  "entities",
  "../views"
], (Marionette, Entities, Views) ->

  class Views.ContentListControls extends Marionette.ItemView

    template: "content/list_controls"

    events:
      "click dd": "updateActive"

    initialize: (opts) ->
      @current_state = "grid"

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

  Views
