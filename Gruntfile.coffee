ALL_TASKS = ['jst:all', 'coffee:all', 'concat:all', 'stylus:all']

# For Zanata pull
process.env['NODE_TLS_REJECT_UNAUTHORIZED'] = '0'

module.exports = (grunt) ->

  path = require('path')
  exec = require('child_process').exec

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-jst')
  grunt.loadNpmTasks('grunt-contrib-stylus')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-zanata-js')
  grunt.loadNpmTasks('grunt-shell')

  grunt.initConfig

    pkg: '<json:package.json>'

    jst:
      all:
        options:
          namespace: 'Formbuilder.templates'
          processName: (filename) ->
            filename.replace('./templates/', '').replace('.html', '')

        files:
          'templates/compiled.js': ['./templates/**/*.html']

    coffee:
      all:
        files:
          'js/compiled.js': ['coffee/rivets-config.coffee', 'coffee/main.coffee', 'coffee/fields/*.coffee']

    concat:
      all:
        src: ['js/compiled.js', 'templates/compiled.js']
        dest: 'formbuilder.js'

    cssmin:
      dist:
        files:
          'formbuilder-min.css': ['formbuilder.css']

    stylus:
      all:
        files:
          'formbuilder.css': 'styl/formbuilder.styl'

    uglify:
      dist:
        files:
          'formbuilder-min.js': 'formbuilder.js'

    watch:
      all:
        files: ['./coffee/**/*.coffee', 'templates/**/*.html', './styl/**/*.styl']
        tasks: ALL_TASKS

    zanata:
      push_fb:
        options:
          url: 'https://translate.engineering.redhat.com'
          project: 'formbuilder'
          'project-version': 'master'
          'project-type': 'gettext'
        files: [
          src: 'po'
          type: 'source'
        ]
      pull_fb:
        options:
          url: 'https://translate.engineering.redhat.com'
          project: 'formbuilder'
          'project-version': 'master'
          'project-type': 'gettext'
        files: [
          src: 'po'
          type: 'trans'
          docId: 'formbuilder'
        ]

    shell:
      js2pot:
        command: 'node gen-pot.js'
      po2json:
        command: 'node po2json.js'

  grunt.registerTask 'default', ALL_TASKS
  grunt.registerTask 'dist', ['cssmin:dist', 'uglify:dist']
  grunt.registerTask 'potupload', ['default', 'shell:js2pot', 'zanata:push_fb']
  grunt.registerTask 'updatetrans', ['zanata:pull_fb', 'shell:po2json']
