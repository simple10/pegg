# CSS
require 'styles/app'

# JS
require 'script!modernizr/modernizr'
$ = require 'jquery'
require 'layout/foundation'
ReactHack = require 'ReactHack'

HomePage = require 'pages/home'
UploadPage = require 'pages/upload'

root = document.getElementById 'root'

# Routes
ReactHack.start root,
  '': HomePage,
  'pages/upload': UploadPage
