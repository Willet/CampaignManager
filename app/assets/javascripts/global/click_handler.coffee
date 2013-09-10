require ['backbone', 'jquery'], (Backbone, $) ->
  # Globally capture clicks. If they are internal and not in the pass
  # through list, route them through Backbone's navigate method.
  $(document).on "click", "a[href^='/']", (event) ->

    href = $(event.currentTarget).attr('href')

    # chain 'or's for other black list routes
    passThrough = href.indexOf('sign_out') >= 0

    # Allow shift+click for new tabs, etc.
    if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
      event.preventDefault()

      # Remove leading slashes and hash bangs (backward compatablility)
      url = href.replace(/^\//,'').replace('\#\!\/','')

      # Instruct Backbone to trigger routing events
      Backbone.history.navigate url, { trigger: true }
      document.body.scrollTop = 0

      return false
