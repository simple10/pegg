// Karma configuration
// Generated on Mon May 19 2014 18:07:06 GMT-0700 (PDT)
// https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/01-configuration-file.md

// TODO: rewrite as coffeescript

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha-debug', 'mocha'],


    // list of files / patterns to load in the browser
    // https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/02-files.md
    files: [
      'src/spec/**/*'
    ],


    // list of files to exclude
    exclude: [

    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    // https://github.com/karma-runner/karma/blob/v0.12.16/docs/config/04-preprocessors.md
    preprocessors: {
      'src/spec/**/*Spec.coffee': ['webpack']
    },

    // http://webpack.github.io/docs/configuration.html
    webpack: {
      cache: true,
      watchDelay: 500,
      debug: false,
      module: {
        // todo: include loaders from webpack.conf.js
        loaders: [
          {
            test: /\.coffee$/,
            loader: 'coffee-loader'
          },
          {
            test: /\.scss$/,
            loader: "style-loader!sass-loader?outputStyle=expanded&includePaths[]=./bower_components/"
          },
          {
            test: /\.css$/,
            loader: 'style-loader!css-loader'
          }
        ]
      },
      resolve: {
        extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js', '.scss'],
        modulesDirectories: ['src', 'src/lib', 'src/app', 'bower_components', 'node_modules']
      }
    },

    // http://webpack.github.io/docs/webpack-dev-server.html
    // https://github.com/webpack/docs/wiki/webpack-dev-middleware
    webpackServer: {
      quiet: true,
      noInfo: true,
      lazy: false,
      watchDelay: 300,
      stats: {
        colors: true
      }
    },

    webpackPort: 1234,

    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['mocha'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG,

    // https://github.com/nomiddlename/log4js-node
    loggers: [
      {type: 'console'}
    ],

    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,
    autoWatchBatchDelay: 500,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    plugins: [
      require("karma-webpack"),
      require("karma-mocha"),
      require("karma-mocha-debug"),
      require("karma-chrome-launcher"),
      require("karma-mocha-reporter")
      // require("karma-safari-launcher")
    ],

    client: {
      useIframe: true,
      captureConsole: true
    }
  });
};
