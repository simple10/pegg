# Karma configuration
# Generated on Mon May 19 2014 18:07:06 GMT-0700 (PDT)
# https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/01-configuration-file.md


webpackConfig = Object.create require('./webpack.config.coffee')

# Override webpack config settings as needed
webpackConfig.debug = true
webpackConfig.cache = true


module.exports = (config) ->
  config.set

    # Base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: ''

    # Frameworks to use
    # Available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: [ 'mocha-debug', 'mocha' ]

    # Files option is ignored when calling karma through gulp.
    # See gulp-karma.
    # list of files / patterns to load in the browser
    # https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/02-files.md
    # files: [
    #   # Watch app files so tests rerun when code changes
    #   {pattern: 'src/app/**/*', included: false, served: false, watched: true}
    #   # Watch tests
    #   'src/spec/**/*'
    # ]

    # Serve images and assets by proxying to the dev server or serving them by karma.
    # proxies:
    #   '/img/': 'http://localhost:8080/base/test/images/'

    # list of files to exclude
    exclude: [
      'src/spec/helpers/**/*'
    ]

    # Preprocess matching files before serving them to the browser.
    # Available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    # https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/04-preprocessors.md
    preprocessors:
      'src/spec/**/*Spec.coffee': [ 'webpack' ]

    # http://webpack.github.io/docs/webpack-dev-server.html
    # https://github.com/webpack/docs/wiki/webpack-dev-middleware
    webpackServer:
      quiet: true
      noInfo: true
      lazy: false
      watchDelay: 300
      stats:
        colors: true

    webpackPort: 1234

    webpack: webpackConfig

    # Test results reporter to use.
    # Possible built-in values: 'dots', 'progress'
    # Available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: [ 'mocha' ]

    # Web server port
    port: 9876

    # Enable / disable colors in the output (reporters and logs)
    colors: true

    # Level of logging
    # Possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG

    # https://github.com/nomiddlename/log4js-node
    loggers: [ type: 'console' ]

    # Enable / disable watching file and executing tests whenever any file changes.
    # Gulp overrides autoWatch.
    # autoWatch: true
    # autoWatchBatchDelay: 500

    # start these browsers
    # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: [ 'Chrome' ]

    # Continuous Integration mode.
    # If true, Karma captures browsers, runs the tests and exits.
    # Gulp overrides singleRun with action option.
    singleRun: false

    plugins: [
      require 'karma-webpack'
      require 'karma-mocha'
      require 'karma-mocha-reporter'
      require 'karma-mocha-debug'
      require 'karma-chrome-launcher'
      # require 'karma-safari-launcher
    ]

    client:
      useIframe: true
      captureConsole: true

