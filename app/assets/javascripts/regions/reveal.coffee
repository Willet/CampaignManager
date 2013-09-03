define ["marionette", "foundation/reveal"], (Marionette, Reveal) ->
  class RevealDialog extends Marionette.Region

    onShow: ->
      @$el.addClass("reveal-modal")
      @$el.foundation('reveal', 'open')
      $('.reveal-modal-bg').on('click', => @close())

    onClose: ->
      @$el.foundation('reveal', 'close')

  return {
    RevealDialog: RevealDialog
  }
