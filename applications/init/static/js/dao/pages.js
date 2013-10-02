define(["app", "dao/base", "entities"], function (App, Base, Entities) {
    var API;
    API = {
        getPage: function (store_id, page_id, params) {
            var page;
            if (params == null) {
                params = {};
            }
            page = new Entities.Page();
            page.url = "" + App.API_ROOT + "/stores/" + store_id + "/pages/" + page_id;
            page.fetch({
                reset: true,
                data: params
            });
            return page;
        },
        getPages: function (store_id, params) {
            var pages;
            if (params == null) {
                params = {};
            }
            pages = new Entities.PageCollection();
            pages.url = "" + App.API_ROOT + "/stores/" + store_id + "/pages";
            pages.fetch({
                reset: true,
                data: params
            });
            return pages;
        },
        newPage: function (store_id, params) {
            var page;
            if (params == null) {
                params = {};
            }
            page = new Entities.Page(params);
            page.set('store-id', store_id);
            page.url = function () {
                return "" + App.API_ROOT + "/stores/" + store_id + "/pages/" + (this.get('id'));
            };
            return page;
        }
    };
    App.reqres.setHandler("page:entities", function (store_id, params) {
        return API.getPages(store_id, params);
    });
    App.reqres.setHandler("page:entity", function (store_id, page_id, params) {
        return API.getPage(store_id, page_id, params);
    });
    return App.reqres.setHandler("new:page:entity",
        function (store_id, params) {
            return API.newPage(store_id, params);
        });
});
