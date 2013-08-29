define [
  "views/main",
  "views/products",
  "views/content",
  "views/pages",
  "views/stores"
], (Main, Products, Content, Pages, Stores) ->
  SecondFunnel.Views = {
    Main: Main
    Products: Products
    Content: Content
    Pages: Pages
    Stores: Stores
  }

