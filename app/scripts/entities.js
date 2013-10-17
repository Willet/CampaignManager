define([
    "entities/base",
    "entities/products",
    "entities/content",
    "entities/pages",
    "entities/stores",
    "entities/scrape",
    "entities/user",
    "exports"
], function (Base, Products, Content, Pages, Stores, Scrape, User, exports) {
    return _.extend(exports, Base, Products, Content, Pages, Stores, Scrape, User);
});