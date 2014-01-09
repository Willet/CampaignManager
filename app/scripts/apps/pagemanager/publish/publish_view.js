define(['app', '../views', 'backbone', 'backbone.stickit'],
    function (App, Views) {
        'use strict';
        Views.PublishPage = App.Views.Layout.extend({
            template: 'page/publish',
            initialize: function (opts) {
                this.store = opts.store;
            },
            serializeData: function () {
                return {
                    page: this.model.toJSON(),
                    url: this.store.get('public-base-url'),
                    store: this.store.toJSON()
                };
            },
            onRender: function () {
                this.stickit();
                this.$('.fail').hide();
            }
        });

        return Views;
    });
