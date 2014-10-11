# See webpack.config.js for more examples:
# http://webpack.github.io/docs/configuration.html
# https://github.com/webpack/webpack-with-common-libs/blob/master/webpack.config.js
# https://github.com/webpack/example-app/blob/master/webpack.config.js

webpack = require 'webpack'
HtmlWebpackPlugin = require 'html-webpack-plugin'
path = require 'path'

# webpack-dev-server options used in gulpfile
# https://github.com/webpack/webpack-dev-server

module.exports =

  # webpack-dev-server base directory
  contentBase: "#{__dirname}/src/assets/"

  cache: true

  entry:
    bundle: './src/app'

  # http://webpack.github.io/docs/configuration.html#devtool
  # eval does not work with code that has 'use strict'; like fastclick.js.
  # eval is not considered production safe.
  # source-map with coffeescript was broken for awhile but seems to be working fine with chrome.
  #devtool: 'eval'
  devtool: 'source-map'

  output:
    path: path.join(__dirname, 'dist')
    publicPath: 'dist/'
    filename: 'bundle.js'
    sourceMapFilename: '[file].map'
    libraryTarget: 'umd'
    # chunkFilename: '[hash]/js/[id].js'
    # hotUpdateMainFilename: "[hash]/update.json",
    # hotUpdateChunkFilename: "[hash]/js/[id].update.js"

  recordsOutputPath: path.join(__dirname, "records.json"),

  module:
    loaders: [
      {
        test: /\.coffee$/
        loader: 'coffee-loader'
      }
      {
        test: /\.scss$/
        loader: "style-loader!sass-loader?outputStyle=expanded&includePaths[]=./bower_components/"
      }
      {
        # required to write 'require('./style.css')'
        test: /\.css$/
        loader: 'style-loader!css-loader'
      }
      # {
      #   test: /\.woff$/
      #   loader: 'url-loader?prefix=font/&limit=5000&minetype=application/font-woff'
      # }
      # {
      #   test: /\.ttf$/
      #   loader: 'file-loader?prefix=font/'
      # }
      # {
      #   test: /\.eot$/
      #   loader: 'file-loader?prefix=font/'
      # }
      # {
      #   test: /\.svg$/
      #   loader: 'file-loader?prefix=font/'
      # }
      # {
      #   # Add to package.json: "jade-loader": "~0.6",
      #   test: /\.jade$/
      #   loader: 'jade-loader?self'
      # }

      # Shim sinon.js loading to fix broken AMD.
      # https://github.com/webpack/webpack/issues/177
      {
        test: /sinon.js$/
        loader: 'imports?define=>false'
      }
    ]


  resolve:
    extensions: ['', '.webpack.js', '.web.js', '.coffee', '.js', '.scss']
    modulesDirectories: ['src', 'src/lib', 'src/app', 'bower_components', 'node_modules']

  plugins: [
    new webpack.optimize.OccurenceOrderPlugin(true)
    new HtmlWebpackPlugin
      # webpack-dev-server is service index.html directly.
      # Not sure how to easily modify this behavior to serve the compiled index.html.tpl;
      # so for now just maintain separate index.html and index.html.tpl
      template: 'src/assets/index.html.tpl'
  ]
