define(['exports', 'app'], function(Loading, App) {
    'use strict';

    Loading.LoadingView = App.Views.ItemView.extend({

        template: 'shared/loading',
        className: 'loading,'

    });

    return Loading;
});