module.exports = (grunt) ->

    # Project configuration
    grunt.initConfig({

        pkg: grunt.file.readJSON('package.json')

        coffee:
            build:
                files:
                    'src/tmp/content-select.js': [
                        'src/content-select.coffee'
                    ]

            spec:
                files:
                    'spec/spec-helper.js': 'src/spec/spec-helper.coffee'
                    'spec/content-select-spec.js': 'src/spec/content-select-spec.coffee'

        uglify:
            options:
                banner: '/*! <%= pkg.name %> v<%= pkg.version %> by <%= pkg.author.name %> <<%= pkg.author.email %>> (<%= pkg.author.url %>) */\n'
                mangle: false

            build:
                src: 'build/content-select.js'
                dest: 'build/content-select.min.js'

        concat:
            build:
                src: [
                    'src/tmp/content-select.js'
                ]
                dest: 'build/content-select.js'

        clean:
            build: ['src/tmp']

        watch:
            build:
                files: ['src/*.coffee']
                tasks: ['build']

            spec:
                files: ['src/spec/*.coffee']
                tasks: ['spec']
    })

    # Plug-ins
    grunt.loadNpmTasks 'grunt-contrib-clean'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-concat'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Tasks
    grunt.registerTask 'build', [
        'coffee:build'
        'concat:build'
        'uglify:build'
        'clean:build'
    ]

    grunt.registerTask 'spec', [
        'coffee:spec'
    ]

    grunt.registerTask 'watch-build', ['watch:build']
    grunt.registerTask 'watch-spec', ['watch:spec']

