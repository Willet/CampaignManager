define [
  "app",
  "dao/base",
  "entities"
], (App, Base, Entities) ->

  API =
    getScraper: (store_id, scraperjob_name, params = {}) ->
      model = new Entities.ScraperJob
      model.url = "#{App.API_ROOT}/scraper/store/#{store_id}/#{scraperjob_name}"
      model.fetch
        reset: true
        data: params
      model

    queueJob: (store_id, scraperjob_name, params = {}) ->
      # TODO: production URL, how to know which environment
      url = "http://scraper-test.elasticbeanstalk.com/queue/store/#{store_id}/#{scraperjob_name}")
      $.ajax(
        method: "GET" # TODO: this should really be a POST ? one for create, one for status?
        url: url
      )

  App.reqres.setHandler "scraper:entity",
    (store_id, scraperjob_name) ->
      API.getScraperJobs store_id, scraperjob_name

  App.reqres.setHandler "scraper:entity:queue",
    (store_id, scraperjob_name) ->
      API.queueJob store_id, scraperjob_name