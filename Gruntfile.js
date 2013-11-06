'use strict';

module.exports = function (grunt) {
    // show elapsed time at the end
    require('time-grunt')(grunt);

    // load all grunt tasks
    require('load-grunt-tasks')(grunt);

    var proxySnippet = require('grunt-connect-proxy/lib/utils').proxyRequest;

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
            style: {
                files: ['<%= yeoman.app %>/styles/**/*.{scss,sass}'],
                tasks: ['autoprefixer']
            },
            templates: {
                files: ['<%= yeoman.app %>/templates/**/*.hbs'],
                tasks: ['handlebars']
            },
            livereload: {
                options: {
                    livereload: '<%= connect.options.livereload %>'
                },
                files: [
                    '<%= yeomap.tmp %>/**/*.{css,js,jpg,jpeg,svg,png}'
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
                    open: true,
                    base: [
                        '<%= yeoman.tmp %>',
                        '<%= yeoman.app %>'
                    ],
                    middleware: function(connect, options) {
                        // https://github.com/gruntjs/grunt-contrib-connect#middleware
                        // Serve static files:
                        var middlewares = [];
                        if (!Array.isArray(options.base)) {
                            options.base = [options.base];
                        }

                        options.base.forEach(function(base) {
                            // Serve static files.
                            middlewares.push(connect.static(base));
                        });

                        // Make directory browse-able.
                        middlewares.push(proxySnippet);
                        return middlewares;
                    }
                }
            },
            test: {
                options: {
                    base: [
                        '<%= yeoman.tmp %>',
                        'test',
                        '<%= yeoman.app %>'
                    ]
                }
            },
            dist: {
                options: {
                    open: true,
                    base: '<%= yeoman.dist %>'
                }
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
                'test/**/*.js',
                '!test/lib/**/*.js'
            ],
            options: {
                jshintrc: '.jshintrc'
            },
        },
        handlebars: {
            compile: {
                options: {
                    amd: true,
                    namespace: 'JST',
                    processName: function (filename) {
                        return filename.replace('app/templates/',
                            '').replace('.hbs', '');
                    },
                    processContent: function (content) {
                        content = content.replace(/^[\x20\t]+/mg,
                            '').replace(/[\x20\t]+$/mg, '');
                        content = content.replace(/^[\r\n]+/,
                            '').replace(/[\r\n]*$/, '\n');
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
            server: {
                options: {
                    watch: true
                }
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
                        cwd: '<%= yeoman.tmp %>/styles/',
                        src: '**/*.css',
                        dest: '<%= yeoman.tmp %>/styles/'
                    }
                ]
            }
        },
        requirejs: {
            dist: {
                options: {
                    // `name` and `out` is set by grunt-usemin
                    baseUrl: '<%= yeoman.tmp %>/scripts',
                    mainConfigFile: '<%= yeoman.tmp %>/scripts/main.js',
                    preserveLicenseComments: false,
                    useStrict: true,
                    wrap: true,
                    stubModules: ['text']
                }
            }
        },
        rev: {
            dist: {
                files: {
                    src: [
                        '<%= yeoman.dist %>/scripts/**/*.js',
                        '<%= yeoman.dist %>/styles/**/*.css',
                        '<%= yeoman.dist %>/images/**/*.{png,jpg,jpeg,gif,webp}',
                        '<%= yeoman.dist %>/styles/fonts/**/*.*'
                    ]
                }
            }
        },
        useminPrepare: {
            options: {
                dest: '<%= yeoman.dist %>'
            },
            html: '<%= yeoman.app %>/index.html'
        },
        usemin: {
            options: {
                dirs: ['<%= yeoman.dist %>']
            },
            html: ['<%= yeoman.dist %>/**/*.html'],
            css: ['<%= yeoman.dist %>/styles/**/*.css']
        },
        // Put files not handled in other tasks here
        sync: {
            images: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>',
                        dest: '<%= yeoman.tmp %>/',
                        src: [
                            'images/**/*.*'
                        ]
                    }
                ]
            },
            js: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>',
                        dest: '<%= yeoman.tmp %>/',
                        src: [
                            'scripts/**/*.js',
                            'scripts/mock/data/**/*.json',
                            'bower_components/**/*.js'
                        ]
                    }
                ]
            },
            dist: {
                files: [
                    {
                        cwd: '<%= yeoman.app %>',
                        dest: '<%= yeoman.dist %>/',
                        src: [
                            '*.{ico,png,txt}',
                            '.htaccess',
                            'images/**/*.{webp,gif}',
                            'styles/fonts/**/*.*',
                            'bower_components/sass-bootstrap/fonts/*.*'
                        ]
                    }
                ]
            },
            styles: {
                expand: true,
                dot: true,
                cwd: '<%= yeoman.app %>/styles',
                dest: '<%= yeoman.tmp %>/styles/',
                src: '**/*.css'
            }
        },
        modernizr: {
            devFile: '<%= yeoman.app %>/bower_components/modernizr/modernizr.js',
            outputFile: '<%= yeoman.dist %>/bower_components/modernizr/modernizr.js',
            files: [
                '<%= yeoman.dist %>/scripts/**/*.js',
                '<%= yeoman.dist %>/styles/**/*.css',
                '!<%= yeoman.dist %>/scripts/vendor/*'
            ],
            uglify: true
        },
        concurrent: {
            server: [
                'watch',
                'compass',
                'connect:livereload'
            ],
            test: [
                'sync:styles'
            ],
            dist: [
                'compass',
                'sync:styles',
                'imagemin',
                'svgmin',
                'htmlmin',
                'handlebars',
                'coffee'
            ]
        },
        bower: {
            options: {
                exclude: ['modernizr']
            },
            all: {
                rjsConfig: '<%= yeoman.app %>/scripts/main.js'
            }
        }
    }); // end of config

    grunt.loadNpmTasks('grunt-contrib-handlebars');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-connect-proxy');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-sync');
    grunt.loadNpmTasks('grunt-concurrent');

    grunt.registerTask('server', function (target) {
        if (target === 'dist') {
            return grunt.task.run(['build', 'connect:dist:keepalive']);
        }

        grunt.task.run([
            'clean:server',
            'configureProxies',
            'jshint',
            'concurrent:server'
        ]);
    });

    grunt.registerTask('test', [
        'clean:server',
        'concurrent:test',
        'autoprefixer',
        'connect:test',
        'mocha'
    ]);

    grunt.registerTask('build', [
        'clean:dist',
        'useminPrepare',
        'concurrent:dist',
        'sync:js',
        'sync:images',
        'autoprefixer',
        'requirejs',
        'concat',
        'cssmin',
        'uglify',
        'modernizr',
        'sync:dist',
        'rev',
        'usemin'
    ]);

    grunt.registerTask('default', [
        'jshint',
        'test',
        'build'
    ]);

};
