require([], function () {
    'use strict';

    //Shim to have window.location.origin in ie
    if (!window.location.origin) {
        window.location.origin = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port: '');
    }
});