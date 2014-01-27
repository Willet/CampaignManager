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

        initialize: function (options) {
            // Expects a collection to be passed as one of
            // the values in the options
            this.loadingTemplate = this.template; // reference to original template
            if (options.collection) {
                this.collection = options.collection;
                this.listenTo(this.collection, 'fail', this.onComplete, this);
                this.listenTo(this.collection, 'reset', this.onReset, this);
            }
        },
        onReset: function () {
            // re-render as loading on reset
            this.template = this.loadingTemplate;
            this.render();
        },
        onComplete: function () {
            // onComplete we want to check if the collection has changed in length, as
            // if it hasn't after a fetch, either there are no more results to show or
            // there were no results to begin with
            if (this.collection.length === 0 && this.emptyTemplate) {
                this.template = this.emptyTemplate;
            } else if (this.collection.length > 0 && this.completeTemplate) {
                this.template = this.completeTemplate;
            }
            this.render();
        }
    });
});
