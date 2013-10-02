define(["entities/base", "entities/products", "entities/content",
        "entities/pages", "entities/stores", "entities/scrape", "exports"],
    function(Base, Products, Content, Pages, Stores, Scrape, exports) {
        return _.extend(exports, Base, Products, Content, Pages, Stores, Scrape);
    });
