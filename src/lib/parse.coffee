# Modularize Parse

require('script!parse-1.2.18_fixed-parsedate')
Config = require('config').public.parse

Parse.initialize Config.appId, Config.jsKey

module.exports = window.Parse
