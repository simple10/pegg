# Configure and modularize Parse

# This is an example of how to shim a library that injects itself
# into the global scope. Other options include using imports
# and exports loaders if the library is parsable by webpack.
# The Parse lib is not safely parsable by webpack.
# See http://webpack.github.io/docs/shimming-modules.html

# Example using imports and exports loaders
# Parse = require 'imports?window=>{}!exports?window.Parse!./parse-1.2.18_fixed-parsedate'

$ = require 'exports?$!../../bower_components/zepto/zepto.js'
require 'script!./parse-1.2.18_fixed-parsedate'
Config = require('Config').public.parse

Parse = window.Parse
delete window.Parse

Parse.initialize Config.appId, Config.jsKey

module.exports = Parse
