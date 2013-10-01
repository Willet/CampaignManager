define [
  "entities/base",
  "entities/products",
  "entities/content",
  "entities/pages",
  "entities/stores",
  "entities/scrape",
  "exports"
], (Base, Products, Content, Pages, Stores, Scrape, exports) ->
  _.extend(exports, Base, Products, Content, Pages, Stores, Scrape)