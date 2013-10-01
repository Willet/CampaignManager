define "app", [
  'marionette',
  'jquery',
  'underscore',
  'entities',
  'components/regions/reveal',
  'exports'
], (Marionette, $, _, Entities, Reveal, exports) ->

  App = window.App = new Marionette.Application()

  App.APP_ROOT = window.APP_ROOT
  App.API_ROOT = "http://contentgraph-test.elasticbeanstalk.com/graph"

  App.addRegions
    modal:
      selector: "#modal"
      regionType: Reveal.RevealDialog
    nav: "header"
    infobar: "#info-bar"
    titlebar: "#title-bar"
    main: "#container"
    footer: "footer"

  App.addInitializer ->
    $(document).ajaxError (event, xhr) ->
      App.redirectToLogin() if (xhr.status == 401)
    App.pageInfo = new Entities.Model(title: "Loading", page: "")

  App.on "initialize:after", (options) ->
    @startHistory()
    @navigate(App.APP_ROOT, trigger: true) unless @getCurrentRoute()

  # TODO: we should really make an authentication method so we do not
  #       hardcode this in here.
  $.ajaxSetup({
    beforeSend: (request) ->
      request.setRequestHeader('ApiKey', 'secretword')
  })

  # Helpful for callback when a set of entities have been fetched
  App.commands.setHandler "when:fetched", (entities, callback) ->
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()
    $.when(xhrs...).done ->
      callback()

  # Handle Unauthorized (Redirect to login, etc...)
  App.redirectToLogin = ->
    window.location = "#{App.APP_ROOT}login?r=#{window.location.hash}"

  App.setTitle = (title) ->
    App.pageInfo.set "title", title

  _.extend(exports, App)
  App
