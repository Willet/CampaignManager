# converted by js2coffee
define "app", [
  "marionette"
  "jquery"
  "underscore"
  "entities"
  "components/regions/reveal"
  "cloudinary"
  "exports"
], (Marionette, $, _, Entities, Reveal, cloudinary, exports) ->
  App = window.App = new Marionette.Application()
  App.APP_ROOT = window.APP_ROOT
  App.ENVIRONMENT = ""
  App.Views = {}
  App.Controllers = {}
  App.rootRoute = ""
  App.addRegions
    modal:
      selector: "#modal"
      regionType: Reveal.RevealDialog

    layout: "#layout"
    header: "header"
    footer: "footer"

  if window.location.hostname is "127.0.0.1" or window.location.hostname is "localhost" # dev
    App.API_ROOT = window.location.origin + "/graph/v1"
    App.ENVIRONMENT = "DEV"
  else if window.location.hostname.indexOf("-test") > 0 # test bucket
    App.API_ROOT = "http://stage.secondfunnel.com/graph/v1"
    App.ENVIRONMENT = "TEST"
  else # assumed production bucket
    App.API_ROOT = "http://production.secondfunnel.com/graph/v1"
    App.ENVIRONMENT = "PRODUCTION"

  # required for test/master; doesn't break dev
  $.cloudinary.config
    cloud_name: "secondfunnel"
    api_key: "471718281466152"
  App.CLOUDINARY_DOMAIN = "http://" + $.cloudinary.SHARED_CDN + "/" +
                          $.cloudinary.config().cloud_name + "/image/upload/"

  App.addInitializer ->
    $(document).ajaxError (event, xhr) ->
      if xhr.status is 401
        console.log "a 401 happened"
        App.redirectToLogin()

  App.on "initialize:after", ->
    @startHistory()
    unless @getCurrentRoute()
      @navigate App.rootRoute,
        trigger: true

  App.commands.setHandler "when:fetched", (entities, callback) ->
    xhrs = undefined
    xhrs = _.chain([entities]).flatten().pluck("_fetch").value()
    $.when.apply($, xhrs).done ->
      callback()

  App.reqres.setHandler "default:region", ->
    App.layout

  App.commands.setHandler "register:instance", (instance, id) ->
    App.register instance, id

  App.commands.setHandler "unregister:instance", (instance, id) ->
    App.unregister instance, id

  App.redirectToLogin = ->
    App.navigate "",
      trigger: true


  # because exports is required (otherwise too many cyclic dependencies)
  # may be able to REVERSE the direction, and make everything else export.
  # but it is a fair bit of work at the current point in time
  _.extend exports, App
  App
