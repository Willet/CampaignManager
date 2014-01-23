define [
  'app',
  '../views',
  'jquery',
  'underscore'
], (App, Views, $, _) ->

  class Views.EditContentView extends Views.TaggedProductInput
    template: 'content/edit/index'

    triggers:
      'click .reveal-close .reveal-modal-bg' : 'closeEditView'
      'keyup .content-caption' : 'captionEditView'

    serializeData: ->
      @model.viewJSON()

  Views
