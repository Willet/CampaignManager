/*global module, require */
'use strict';

module.exports = function (grunt) {
    // show elapsed time at the end
    require('time-grunt')(grunt);

    // load all grunt tasks
    require('load-grunt-tasks')(grunt);

    var proxySnippet = require('grunt-connect-proxy/lib/utils').proxyRequest;
    var connectMiddleware = function(connect, options) {
        var middlewares = [];
        var directory = options.directory || options.base[options.base.length - 1];
        if (!Array.isArray(options.base)) {
            options.base = [options.base];
        }

        options.base.forEach(function(base) {
            // Serve static files.
            middlewares.push(connect.static(base));
        });

        // Make directory browse-able.
        middlewares.push(connect.directory(directory));

        // Setup a proxy for local development
        middlewares.push(proxySnippet);

        return middlewares;
    };

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        // configurable paths
        yeoman: {
            app: 'app',
            dist: 'dist',
            test: 'test',
            tmp: '.tmp'
        },
        uglify: {
            options: {
                mangle: false,
                exportAll: true
            }
        },
        watch: {
            coffee: {
                files: ['<%= yeoman.app %>/scripts/**/*.coffee'],
                tasks: ['coffee']
            },
            js: {
                files: ['<%= yeoman.app %>/scripts/**/*.js'],
                tasks: ['sync:js', 'jshint']
            },
            templates: {
                files: ['<%= yeoman.app %>/templates/**/*.hbs'],
                tasks: ['handlebars']
            },
            images: {
                files: ['<%= yeoman.app %>/**/*.{ico,png,jpeg,jpg,svg}'],
                tasks: ['sync:images']
            },
            livereload: {
                options: {
                    livereload: '<%= connect.options.livereload %>',
                    debounceDelay: 1,
                    interval: 1
                },
                tasks: [],
                files: [
                    '<%= yeoman.tmp %>/styles/app.css', //{css,js,jpg,jpeg,svg,png,hbs}'
                    '<%= yeoman.tmp %>/scripts/**/*.js'
                ]
            }
        },
        connect: {
            options: {
                port: 9000,
                livereload: 35729,
                // change this to '0.0.0.0' to access the server from outside
                hostname: 'localhost'
            },
            livereload: {
                options: {
                    base: [
                        '<%= yeoman.tmp %>'
                    ],
                    middleware: connectMiddleware
                }
            },
            test: {
                options: {
                    base: [
                        'test',
                        '<%= yeoman.tmp %>'
                    ],
                    middleware: connectMiddleware
                }
            },
            dist: {
                options: {
                    open: true,
                    base: '<%= yeoman.dist %>'
                },
                middleware: connectMiddleware
            },
            proxies: [{
                context: '/graph/v1',
                host: 'localhost',
                port: 8000,
                https: false,
                changeOrigin: false,
                xforward: false
            }]
        },
        clean: {
            dist: {
                files: [
                    {
                        dot: true,
                        src: [
                            '<%= yeoman.tmp %>',
                            '<%= yeoman.dist %>/*',
                            '!<%= yeoman.dist %>/.git*'
                        ]
                    }
                ]
            },
            server: '<%= yeoman.tmp %>'
        },
        jshint: {
            files: [
                'Gruntfile.js',
                '<%= yeoman.app %>/scripts/**/*.js',
                '!<%= yeoman.app %>/scripts/vendor/*',
                '!<%= yeoman.app %>/scripts/lib/*',
                '!test/**/*.js',
                '!test/lib/**/*.js'
            ],
            options: {
                jshintrc: '.jshintrc'
            }
        },
        handlebars: {
            compile: {
                options: {
                    amd: true,
                    namespace: 'JST',
                    processName: function (filename) {
                        return filename.replace('app/templates/', '').replace('.hbs', '');
                    },
                    processContent: function (content) {
                        content = content.replace(/^[\x20\t]+/mg, '').replace(/[\x20\t]+$/mg, '');
                        content = content.replace(/^[\r\n]+/, '').replace(/[\r\n]*$/, '\n');
                        return content;
                    }
                },
                files: {
                    '<%= yeoman.tmp %>/scripts/templates.js': ['<%= yeoman.app %>/templates/**/*.hbs']
                }
            }
        },
        mocha: {
            all: {
                options: {
                    run: true,
                    urls: ['http://<%= connect.test.options.hostname %>:<%= connect.test.options.port %>/index.html']
                }
            }
        },
        coffee: {
            dist: {
                files: [
                    {
                        expand: true,
                        cwd: '<%= yeoman.app %>/scripts',
                        src: '**/*.coffee',
                        dest: '.tmp/scripts',
                        ext: '.js'
                    }
                ]
            },
            test: {
                files: [
                    {
                        expand: true,
                        cwd: '<%= yeoman.test %>/spec',
                        src: '**/*.coffee',
                        dest: '.tmp/spec',
                        ext: '.js'
                    }
                ]
            }
        },
        compass: {
            options: {
                sassDir: '<%= yeoman.app %>/styles',
                cssDir: '<%= yeoman.tmp %>/styles',
                generatedImagesDir: '<%= yeoman.tmp %>/images/generated',
                imagesDir: '<%= yeoman.app %>/images',
                javascriptsDir: '<%= yeoman.app %>/scripts',
                fontsDir: '<%= yeoman.app %>/styles/fonts',
                importPath: '<%= yeoman.app %>/bower_components',
                httpImagesPath: '/images',
                httpGeneratedImagesPath: '/images/generated',
                httpFontsPath: '/styles/fonts',
                relativeAssets: false,
                assetCacheBuster: false
            },
            dist: {
                options: {
                    generatedImagesDir: '<%= yeoman.dist %>/images/generated',
                    environment: 'production'
                }
            },
            watch: {
                options: {
                    watch: true
                }
            },
            server: {
            }
        },
        autoprefixer: {
            options: {
                browsers: ['last 1 version']
            },
            dist: {
                files: [
                    {
                        expand: true,
                        cwd: '<%= yeoman.tmp %>/styles',
                        src: '**/*.css',
                        dest: '<%= yeoman.tmp %>/styles'
                    }
                ]
            }
        },
        requirejs: {
            dist: {
                options: {
                    name: 'config',
                    out: '<%= yeoman.dist %>/scripts/config.js',
                    baseUrl: '<%= yeoman.tmp %>/scripts',
                    mainConfigFile: '<%= yeoman.tmp %>/scripts/config.js',
                    preserveLicenseComments: false,
                    useStrict: true,
                    wrap: true,
                    wrapShim: true,
                    stubModules: ['text'],
                    loglevel: 0
                }
            }
        },
        rev: { // cache-busting utility (adds hash to filenames)
            dist: {
                files: {
                    src: [
                        '<%= yeoman.dist %>/scripts/**/*.js',
                        '<%= yeoman.dist %>/styles/**/*.css',
                        // '<%= yeoman.dist %>/images/**/*.{png,jpg,jpeg,gif,webp}',
                        '<%= yeoman.dist %>/styles/fonts/**/*.*'
                    ]
                }
            }
        },
        useminPrepare: {
            html: '<%= yeoman.app %>/index.html',
            options: {
                dest: '<%= yeoman.dist %>/'
            }
        },
        usemin: {
            html: '<%= yeoman.dist %>/index.html',
            css: '<%= yeoman.dist %>/styles/app.css'
        },
        // Put files not handled in other tasks here
        sync: {
            images: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>/',
                        dest: '<%= yeoman.tmp %>/',
                        src: [
                            'images/**/*.*',
                            '.favicon.ico'
                        ]
                    }
                ]
            },
            js: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>/',
                        dest: '<%= yeoman.tmp %>/',
                        src: [
                            'scripts/**/*.js',
                            'scripts/mock/data/**/*.json',
                            'bower_components/**/*.js'
                        ]
                    }
                ]
            },
            styles: {
                expand: true,
                dot: true,
                cwd: '<%= yeoman.app %>/styles/',
                dest: '<%= yeoman.tmp %>/styles/',
                src: '**/*.css'
            },
            dev: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>/',
                        dest: '<%= yeoman.tmp %>/',
                        src: [
                            'bower_components/requirejs/require.js',
                            '*.{ico,png,txt}',
                            '.htaccess',
                            'index.html',
                            'robots.txt',
                            'images/**/*.{webp,gif,jpg,jpeg,png}',
                            'styles/fonts/**/*.*'
                        ]
                    }
                ]
            },
            dist: {
                files: [
                    {
                        cwd: '<%= yeoman.tmp %>/',
                        dest: '<%= yeoman.dist %>/',
                        src: [
                            'bower_components/requirejs/require.js',
                            '*.{ico,png,txt}',
                            '.htaccess',
                            'index.html',
                            'robots.txt',
                            'images/**/*.{webp,gif,jpg,jpeg,png}',
                            'styles/fonts/**/*.*'
                        ]
                    }
                ]
            }
        },
        concurrent: {
            server: {
                tasks: [
                    'watch:coffee',
                    'watch:js',
                    'watch:templates',
                    'watch:images',
                    'watch:livereload',
                    'compass:watch'
                ],
                options: {
                    logConcurrentOutput: true
                }
            },
            test: [
                'sync:styles',
                'coffee',
                'compass:dist'
            ],
            dist: [
                'coffee'
            ]
        },
        bower: {
            options: {
                exclude: ['modernizr']
            },
            all: {
                rjsConfig: '<%= yeoman.app %>/scripts/config.js'
            }
        }
    }); // end of config

    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-handlebars');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-connect-proxy');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-rev');
    grunt.loadNpmTasks('grunt-sync');
    grunt.loadNpmTasks('grunt-usemin');

    grunt.registerTask('server', function (target) {
        if (target === 'dist') {
            return grunt.task.run(['build', 'configureProxies', 'connect:dist:keepalive']);
        }

        return grunt.task.run([
            'clean:server',
            'compass:server',
            'buildSources',
            'jshint',
            'configureProxies',
            'connect:livereload',
            'concurrent:server'
        ]);
    });

    grunt.registerTask('test', [
        'clean:server',
        'buildSources',
        'concurrent:test',
        'autoprefixer',
        'configureProxies',
        'connect:test:keepalive', // add :keepalive and visit localhost:9000 to debug test environment
        'mocha'
    ]);

    grunt.registerTask('buildSources', [
        'handlebars',
        'coffee',
        'sync:js',
        'sync:styles',
        'sync:images',
        'sync:dev',
        'autoprefixer'
    ]);

    grunt.registerTask('build', [
        // clean
        'clean:server',
        'clean:dist',
        // setup build config
        'useminPrepare',
        // build everything
        'compass:server',
        'buildSources',
        'jshint',
        'compass:dist',
        'sync:dist',
        'requirejs:dist',
        // save some bytes
        'uglify',
        'concat',
        'cssmin',
        // rename files for cache
        'rev',
        // write modified index.html out
        'usemin'
    ]);

    grunt.registerTask('default', [
        'jshint',
        'test',
        'build',
        'sync'
    ]);

};
