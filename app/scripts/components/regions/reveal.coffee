define ["marionette", "foundation/foundation.reveal"], (Marionette, Reveal) ->
  class RevealDialog extends Marionette.Region

    onShow: () ->
      @$el.addClass("reveal-modal")
      @animationSpeed = 250
      @$el.foundation('reveal', 'open',
        animationSpeed: @animationSpeed
      )
      @$el.bind('closed', => @close())
      $('.reveal-modal-bg').on('click', => @$el.foundation('reveal', 'close'))
      @$el.find('.reveal-close').on('click', => @$el.foundation('reveal', 'close'))

    onClose: () ->
      @$el.removeClass("reveal-modal")

  return {
    RevealDialog: RevealDialog
  }
