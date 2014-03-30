# Modularize Parse

Parse = require('../node_modules/parse').Parse
config = require('config').secrets.parse

Parse.initialize config.appId, config.jsKey

module.exports = Parse
