# See example gulpfile.js for file system development build:
# https://github.com/webpack/webpack-with-common-libs/blob/master/gulpfile.js

enableGzip = false

gulp = require 'gulp'
gutil = require 'gulp-util'
clean = require 'gulp-clean'
gzip = require 'gulp-gzip' if enableGzip
webpack = require 'webpack'
WebpackDevServer = require 'webpack-dev-server'
webpackConfig = require './webpack.config.coffee'

conf = Object.create webpackConfig

src = 'src/'
dist = conf.output.path

copyFiles = [
  '**/images/**'
  '**/*.html'
]
gzipFiles = [
  '**/images/**'
  '**/*.js'
  '**/*.html'
]


# Default task
gulp.task 'default', ['help'], ->

gulp.task 'help', ->
  gutil.log "\n\nUsage:\n\n" \
  + "    gulp serve        (build and run dev server)\n" \
  + "    gulp clean        (clean production build dir)\n" \
  + "    gulp build        (production build)\n"



############################################################
# Development build
############################################################
gulp.task 'serve', ['webpack-dev-server'], ->
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
gulp.task 'build', ['webpack:build', 'copy'], ->
  if enableGzip
    gulp.src gzipFiles, cwd: dist
    .pipe gzip()
    .pipe gulp.dest dist

gulp.task 'webpack:build', (callback) ->
  conf.output.filename = 'bundle-[hash].js'
  conf.plugins = conf.plugins.concat(
    new webpack.DefinePlugin 'process.env': { NODE_ENV: JSON.stringify('production') }
    new webpack.optimize.DedupePlugin()
    new webpack.optimize.UglifyJsPlugin()
  )
  # run webpack
  webpack conf, (err, stats) ->
    throw new gutil.PluginError('webpack:build', err) if err
    gutil.log "[webpack:build]\n\n" \
      + stats.toString colors: true
    callback()

gulp.task 'clean', ->
  gulp.src dist, read: false
  .pipe clean()

gulp.task 'copy', ['clean'], ->
  gulp.src copyFiles, cwd: src
  .pipe gulp.dest dist



# path = require 'path'
# express = require 'express'
# # sass = require('gulp-sass')
# # minifyCSS = require('gulp-minify-css')
# clean = require 'gulp-clean'
# watch = require 'gulp-watch'
# # rev = require 'gulp-rev'
# tiny_lr = require 'tiny-lr'
# webpack = require 'webpack'

# #
# # CONFIGS
# #

# webpackConfig = require("./webpack.config.js")
# # test for --production option
# if gulp.env.production
#   webpackConfig.plugins = webpackConfig.plugins.concat new webpack.optimize.UglifyJsPlugin
#   webpackConfig.output.filename = 'main-[hash].js'
# # sassConfig = { includePaths : ['src/styles'] }
# httpPort = 4000
# # paths to files in bower_components that should be copied to dist/assets/vendor
# # vendorPaths = ['es5-shim/es5-sham.js', 'es5-shim/es5-shim.js', 'bootstrap/dist/css/bootstrap.css']


# # main.scss should @include any other CSS you want
# # gulp.task 'sass', ->
# #   gulp.src('src/styles/main.scss')
# #   .pipe(sass(sassConfig).on('error', gutil.log))
# #   .pipe(if gulp.env.production then minifyCSS() else gutil.noop())
# #   .pipe(if gulp.env.production then rev() else gutil.noop())
# #   .pipe(gulp.dest('dist/assets'))

# # Some JS and CSS files we want to grab from Bower and put them in a dist/assets/vendor directory
# # For example, the es5-sham.js is loaded in the HTML only for IE via a conditional comment.
# # gulp.task 'vendor', ->
# #   paths = vendorPaths.map (p) -> path.resolve("./bower_components", p)
# #   gulp.src(paths)
# #   .pipe(gulp.dest('dist/assets/vendor'))

# # Just copy over remaining assets to dist. Exclude the styles and scripts as we process those elsewhere
# # gulp.task 'copy', ->
# #   gulp.src(['src/**/*', '!src/scripts', '!src/scripts/**/*', '!src/styles', '!src/styles/**/*']).pipe(gulp.dest('dist'))

# # This task lets Webpack take care of all the coffeescript and JSX transformations, defined in webpack.config.js
# # Webpack also does its own uglification if we are in --production mode
# gulp.task 'webpack', (callback) ->
#   execWebpack(webpackConfig)
#   callback()

# gulp.task 'serve', ['build'], ->
#   servers = createServers(httpPort, 35729)
#   # When /src changes, fire off a rebuild
#   gulp.watch ['./src/**/*'], (evt) -> gulp.run 'build'
#   # When /dist changes, tell the browser to reload
#   gulp.watch ['./dist/**/*'], (evt) ->
#     gutil.log(gutil.colors.cyan(evt.path), 'changed')
#     servers.lr.changed
#       body:
#         files: [evt.path]


# gulp.task 'build', ['webpack'], ->
# gulp.task 'default', ['build'], ->
#   # Give first-time users a little help
#   setTimeout ->
#     gutil.log "**********************************************"
#     gutil.log "* gulp              (development build)"
#     gutil.log "* gulp clean        (rm /dist)"
#     gutil.log "* gulp --production (production build)"
#     gutil.log "* gulp serve        (build and run dev server)"
#     gutil.log "**********************************************"
#   , 3000
# #
# # HELPERS
# #


# # Create both http server and livereload server
# createServers = (port, lrport) ->
#   lr = tiny_lr()
#   lr.listen lrport, -> gutil.log("LiveReload listening on", lrport)
#   app = express()
#   app.use(express.static(path.resolve("./dist")))
#   app.listen port, -> gutil.log("HTTP server listening on", port)

#   lr: lr
#   app: app

# execWebpack = (config) ->
#   webpack config, (err, stats) ->
#     if (err) then throw new gutil.PluginError("execWebpack", err)
#     gutil.log("[execWebpack]", stats.toString({colors: true}))

