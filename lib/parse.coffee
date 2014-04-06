# Modularize Parse

Parse = require('../node_modules/parse').Parse
Config = require('config').public.parse

Parse.initialize Config.appId, Config.jsKey

module.exports = Parse
