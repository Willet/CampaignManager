#
# Data Mocking Library
# =============================================================================
#
# This uses sinon to partially mock the api. This lets us use our full api
# while mocking new endpoints or new versions of responses. This way we can
# drive ahead on new features and consider the json a contract that the api
# must fulfill.
#
# See the mock_routes file to supply an array of url/response pairings that
# this module will provide. The [Sinon library][sinon] is going to intercept
# the XHR request and provide those responses. The app is never going to know
# that the data didn't come from your ajax provider of choice.
#
# * Author: [Craig Davis](craig@there4development.com)
# * Since: 3/21/2013
#
# [sinon]: http://sinonjs.org/
#
# -----------------------------------------------------------------------------
#
define ["underscore", "mock/mock_routes", "sinon"], (_, mocks) ->
  "use strict"
  sinon = window.sinon
  #fakeXhr = undefined
  server = undefined
  mockedUrls = undefined
  #fakeXhr = sinon.useFakeXMLHttpRequest()
  server = sinon.fakeServer.create()
  mockedUrls = _.pluck(mocks, "url")
  server.autoRespond = true # Don't wait for a manual prompt
  #server.autoRespondAfter = 250 # Milliseconds

  # Allow the mock and api to work together
  sinon.FakeXMLHttpRequest.useFilters = true

  # Tell the fake server which urls we're mocking/intercepting
  sinon.FakeXMLHttpRequest.addFilter (method, url, async, username, password) ->
    useMockData = false
    _.each mocks, (mocked) ->
      if (_.isRegExp(mocked.url) and mocked.url.test(url)) or (mocked.url is url)
        if mocked.method == method
          useMockData = true

    if useMockData
      console.log "[MOCKED]", method, url

    # When this returns truthy the request is __not__ faked.
    not useMockData

  # Map each URL to response, we could implement a mocks.method here
  _.each mocks, (mock) ->
    server.respondWith mock.method, mock.url, [200, { "Content-Type": "application/json" }, mock.response]
