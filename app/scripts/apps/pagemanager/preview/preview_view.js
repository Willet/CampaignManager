define(['app', '../views', 'backbone.stickit'],
    function (App, Views) {
        'use strict';
        Views.PagePreview = App.Views.Layout.extend({
            'template': 'page/view',
            'triggers': {
                'click .publish': 'publish'
            },
            initialize: function (opts) {
                this.store = opts.store;
            },
            serializeData: function () {
                var store = this.store.toJSON(),
                    page = this.model.toJSON(),
                    domain = this.store.get('public-base-url')
                        .replace(/https?:\/\//i, '')
                        .replace(/\/$/, ''),
                    path = page.url;

                if (path.substring(0, 1) === '/') {
                    path = path.substring(1);
                }
                
                if (path.substring(0, 1) === '/') {
                    path = path.substring(1);
                }

                if (App.ENVIRONMENT === 'DEV') {
                    domain = 'dev-' + domain;
                } else if (App.ENVIRONMENT === 'TEST') {
                    domain = 'test-' + domain;
                }

                return {
                    'result': {
                        'bucket_name': domain,
                        's3_path': path
                    },
                    'url': 'http://' + domain + '/' + path,
                    page: page,
                    store: store
                };
            }
        });

        return Views;
    });
