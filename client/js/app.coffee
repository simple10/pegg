require 'head'
$ = require 'jquery'
require 'foundation'

react = require 'ReactHack'

body = require('../home.jade')()

$ ->
  $('body').html(body)
