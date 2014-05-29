# Configure and modularize Parse

# This is an example of how to shim a library that injects itself
# into the global scope. Other options include using webpack loaders
# to prevent global scope pollution.
# See http://webpack.github.io/docs/shimming-modules.html

require('script!parse-1.2.18_fixed-parsedate')
Config = require('config').public.parse

Parse.initialize Config.appId, Config.jsKey

module.exports = window.Parse
