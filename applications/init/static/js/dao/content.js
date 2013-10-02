define(["app", "dao/base", "entities"], function (App, Base, Entities) {
    var API;
    API = {
        getContent: function (store_id, content_id, params) {
            var contents;
            if (params == null) {
                params = {};
            }
            contents = new Entities.Content();
            contents.url = "" + App.API_ROOT + "/stores/" + store_id + "/content/" + content_id;
            contents.fetch({
                reset: true,
                data: params
            });
            return contents;
        },
        getContents: function (store_id, params) {
            var contents;
            if (params == null) {
                params = {};
            }
            contents = new Entities.ContentCollection();
            contents.url = "" + App.API_ROOT + "/stores/" + store_id + "/content";
            contents.fetch({
                reset: true,
                data: params
            });
            return contents;
        },
        getPagedContents: function (store_id, params) {
            var contents;
            if (params == null) {
                params = {};
            }
            contents = new Entities.ContentPageableCollection();
            contents.url = "" + App.API_ROOT + "/stores/" + store_id + "/content";
            contents.getNextPage();
            return contents;
        }
    };
    App.reqres.setHandler("content:entities", function (store_id, params) {
        return API.getContents(store_id, params);
    });
    App.reqres.setHandler("content:entities:paged",
        function (store_id, params) {
            return API.getPagedContents(store_id, params);
        });
    return App.reqres.setHandler("content:entity",
        function (store_id, content_id, params) {
            return API.getContent(store_id, content_id, params);
        });
});
