define(["entities/base", "entities/products", "entities/content", "entities/pages", "entities/stores", "entities/productsource", "entities/scraperjob", "underscore", "exports"],
    function (Base, Products, Content, Pages, Stores, ProductSource, ScraperJob, _, exports) {
        return _.extend(exports, Base, Products, Content, Pages, Stores,
            ProductSource, ScraperJob);
    });
