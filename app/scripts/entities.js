define([
    "entities/base",
    "entities/products",
    "entities/content",
    "entities/pages",
    "entities/stores",
    "entities/scrape",
    "entities/tile-config",
    "entities/user",
    "exports"
], function (Base, Products, Content, Pages, Stores, Scrape, TileConfig, User, exports) {
    return _.extend(exports, Base, Products, Content, Pages, Stores, Scrape, TileConfig, User);
});