define(['exports', 'backboneprojections', 'underscore', 'apps/contentmanager/views'],
    function (ContentList, BackboneProjections, _, ContentViews) {
        ContentList.createView = function (collection, actions) {
            var contentList, contentListControls, layout, multiEditView, selectedCollection,
                _this = this;
            if (actions == null) {
                actions = {};
            }
            layout = new ContentViews.ContentIndexLayout();
            selectedCollection = new BackboneProjections.Filtered(collection, {
                filter: (function (m) {
                    return m.get('selected') === true;
                })
            });
            contentList = new ContentViews.ContentList({
                collection: collection,
                actions: actions
            });
            contentListControls = new ContentViews.ContentListControls();
            multiEditView = new ContentViews.ContentEditArea({
                model: selectedCollection,
                actions: actions
            });
            layout.on("change:sort-order", function (new_order) {
                return collection.updateSortOrder(new_order);
            });
            contentListControls.on("change:state", function (state) {
                if (state === "grid") {
                    return layout.multiedit.$el.css("display", "block");
                } else {
                    return layout.multiedit.$el.css("display", "none");
                }
            });
            contentList.on("itemview:content:approve", function (view, args) {
                return args.model.approve();
            });
            contentList.on("itemview:content:reject", function (view, args) {
                return args.model.reject();
            });
            contentList.on("itemview:content:undecided",
                function (view, args) {
                    return args.model.undecided();
                });
            contentList.on("itemview:edit:tagged-products:add",
                function (view, editArea, tagger, product) {
                    view.model.get('tagged-products').add(product);
                    return view.model.save();
                });
            contentList.on("itemview:edit:tagged-products:remove",
                function (view, editArea, tagger, product) {
                    view.model.get('tagged-products').remove(product);
                    return view.model.save();
                });
            contentList.on("itemview:content:select-toggle",
                function (view, args) {
                    return args.model.set("selected",
                        !args.model.get("selected"));
                });
            contentList.on("itemview:content:preview", function (view, args) {
                return App.modal.show(new ContentViews.ContentQuickView({
                    model: args.model
                }));
            });
            multiEditView.on("content:approve", function (args) {
                var models;
                args.model.collect(function (m) {
                    return m.approve();
                });
                models = _.clone(args.model.models);
                return _.each(models, function (m) {
                    return m.set('selected', false);
                });
            });
            multiEditView.on("content:reject", function (args) {
                var models;
                args.model.collect(function (m) {
                    return m.reject();
                });
                models = _.clone(args.model.models);
                return _.each(models, function (m) {
                    return m.set('selected', false);
                });
            });
            multiEditView.on("content:undecided", function (args) {
                var models;
                args.model.collect(function (m) {
                    return m.undecided();
                });
                models = _.clone(args.model.models);
                return _.each(models, function (m) {
                    return m.set('selected', false);
                });
            });
            layout.on("content:select-all", function () {
                return collection.selectAll();
            });
            layout.on("content:unselect-all", function () {
                return collection.unselectAll();
            });
            layout.on("fetch:next-page", function () {
                return $.when(collection.getNextPage()).done(function () {
                    return layout.trigger("fetch:next-page:complete");
                });
            });
            layout.on("show", function () {
                layout.list.show(contentList);
                layout.listControls.show(contentListControls);
                return layout.multiedit.show(multiEditView);
            });
            return layout;
        };
        return ContentList;
    });
