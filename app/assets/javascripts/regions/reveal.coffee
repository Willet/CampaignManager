define ["marionette", "foundation/reveal"], (Marionette, Reveal) ->
  class RevealDialog extends Marionette.Region

    onShow: () ->
      @$el.addClass("reveal-modal")
      @animationSpeed = 250
      @$el.foundation('reveal', 'open',
       animationSpeed: @animationSpeed
      )
      $('.reveal-modal-bg').on('click', => @close())
      @$el.find('.reveal-close').on('click', => @close())

    onClose: (view) ->
      @$el.foundation('reveal', 'close')

  return {
    RevealDialog: RevealDialog
  }
