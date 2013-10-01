define [
  "text!mock/data/store.json",
  "text!mock/data/stores.json",
  "text!mock/data/page.json",
  "text!mock/data/pages.json",
  "text!mock/data/contents.json"
], (
  storeFixture,
  storesFixture,
  pageFixture,
  pagesFixture,
  contentsFixture
) ->

  [
    {
      method: "GET"
      url: /graph\/stores\/?$/
      response: storesFixture
    },
    {
      method: "GET"
      url: /graph\/stores\/\d+\/?$/
      response: storeFixture
    },
    {
      method: "GET"
      url: /graph\/stores\/\d+\/pages\/?$/
      response: pagesFixture
    },
    {
      method: "GET"
      url: /graph\/stores\/\d+\/pages\/\d+\/?$/
      response: pageFixture
    },
    {
      method: "GET"
      url: /graph\/stores\/\d+\/content\/?/
      response: contentsFixture
    }
  ]
