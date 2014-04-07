# CSS
require 'styles/app'

# JS
require 'script!modernizr/modernizr'
$ = require 'jquery'
require 'layout/foundation'
ReactHack = require 'ReactHack'
require 'facebook'


HomePage = require 'pages/home'

root = document.getElementById 'root'

# Routes
ReactHack.start root,
  '': HomePage
