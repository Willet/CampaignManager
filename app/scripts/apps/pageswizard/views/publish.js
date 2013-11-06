define(['marionette', '../views', 'backbone', 'backbone.stickit'],
    function (Marionette, Views) {
        'use strict';
        Views.PublishPage = Marionette.Layout.extend({
            'regions': {
                'fail': '.fail'
            },
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
            triggers: {
                'click .js-next': 'publish'
            },
            onRender: function () {
                this.stickit();
                this.$('.fail').hide();

                return this.$('.steps .publish').addClass('active');
            }
        });

        return Views;
    });
