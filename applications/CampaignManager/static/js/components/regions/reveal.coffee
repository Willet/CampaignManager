define ["marionette", "foundation/reveal"], (Marionette, Reveal) ->
  class RevealDialog extends Marionette.Region

    onShow: () ->
      @$el.addClass("reveal-modal")
      @animationSpeed = 250
      @$el.foundation('reveal', 'open',
       animationSpeed: @animationSpeed
       closed: => @close()
      )
      $('.reveal-modal-bg').on('click', => @$el.foundation('reveal', 'close'))
      @$el.find('.reveal-close').on('click', => @$el.foundation('reveal', 'close'))

    onClose: (view) ->
      @$el.removeClass("reveal-modal")

  return {
    RevealDialog: RevealDialog
  }
