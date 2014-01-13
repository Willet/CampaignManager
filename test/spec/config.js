'use strict';

require.config({
    baseUrl: '../scripts',
    deps: ['runner'],
    paths: {
        spec: '../spec',
        runner: '../spec/runner',
        appConfig: '../scripts/config',
        chai: '../bower_components/chai/chai'
    },
    shim: {
        runner: ['appConfig']
    }
});
