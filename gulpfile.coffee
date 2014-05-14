# See example gulpfile.js for file system development build:
# https://github.com/webpack/webpack-with-common-libs/blob/master/gulpfile.js

gulp = require 'gulp'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackConfig = require './webpack.config.coffee'

src = 'src/'

copyFiles = [
  '**/images/**'
]

conf = Object.create webpackConfig


# Default task
gulp.task 'default', ['help'], ->

gulp.task 'help', ->
  gutil.log "\n\nUsage:\n\n" \
  + "    gulp serve        (build and run dev server)\n" \
  + "    gulp build        (production build)\n"



############################################################
# Development build
############################################################
gulp.task 'webpack-dev-server', (callback) ->
  conf.debug = true

  # Start a webpack-dev-server
  new WebpackDevServer webpack(conf),
    contentBase: conf.contentBase
    # hot: true
    quiet: false
    noInfo: false
    # lazy: false
    watchDelay: 300
    stats:
      colors: true
  .listen 8080, '', (err) ->
    throw new gutil.PluginError('webpack-dev-server', err) if err
    gutil.log '[webpack-dev-server]', 'http://localhost:8080/webpack-dev-server/index.html'


############################################################
# Production build
############################################################
gulp.task 'build', ['clean', 'webpack:build', 'copy'], ->
gulp.task 'webpack:build', (callback) ->
  conf.output.filename = 'bundle-[hash].js'

  conf.plugins = conf.plugins.concat(
    # new webpack.DefinePlugin 'process.env': { NODE_ENV: JSON.stringify('production') }
    # new webpack.optimize.DedupePlugin()
    new webpack.optimize.UglifyJsPlugin()
  )

  # run webpack
  webpack conf, (err, stats) ->
    throw new gutil.PluginError('webpack:build', err) if err
    gutil.log '[webpack:build]', stats.toString colors: true
    callback()


gulp.task 'clean', ->
  gulp.src conf.output.path, read: false
  .pipe clean()


#  gulp.src(['src/**/*', '!src/scripts', '!src/scripts/**/*', '!src/styles', '!src/styles/**/*']).pipe(gulp.dest('dist'))


gulp.task 'copy', ->
  gulp.src copyFiles, cwd: src
  .pipe gulp.dest conf.output.path


