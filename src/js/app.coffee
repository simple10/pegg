require 'head'
$ = require 'jquery'
require 'foundation'

body = require('../home.jade')()

$ ->
  $('body').html(body)
