define(['app', 'marionette'], function (App, Marionette) {
    'use strict';
    App.Views.ItemView = Marionette.ItemView.extend({
        serializeData: function() {
            if (this.model) {
                return this.model.viewJSON();
            }
            return {};
        }
    });

    App.Views.ItemLoadingView = App.Views.ItemView.extend({
        tagName: 'div',
        loading: true,

        initialize: function (options) {
            // Excepts a collection to be passed as one of
            // the values in the options
            this.collection = options.collection;
            this.listenTo(this.collection, 'fetch', this.onFetch);
            this.listenTo(this.collection, 'sync', this.onFetchComplete);
            this.length = 0;
        },
        onFetch: function () {
            if (!this.loading) { // if not loading, we show
                this.loading = true; // mark as loading
                this.$el.show();
            }
        },
        onFetchComplete: function () {
            if (this.loading) {
                // want to avoid this being called when it obviously
                // shouldn't be
                var $parent = this.$el.parent();
                this.loading = false;
                // detach from DOM and re-add to parent
                // this logic is a bit more specific to our case as Marionette
                // does not have a good way of doing this.
                $parent.append(this.$el.detach());
            }
        }
    });
});
