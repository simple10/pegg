# CSS
require 'styles/app'
require 'famous/core/famous.css'

# JS
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'

Engine = require 'famous/core/Engine'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'

require 'facebook'


# HomePage = require 'pages/home'
# CreateQuestionPage = require 'pages/questions/create'


# Routes


#globals define


# create the main context
mainContext = Engine.createContext()

# your app here
logo = new ImageSurface
  size: [200, 200]
  content: 'images/famous_logo.png'

logoModifier = new StateModifier origin: [0.5, 0.5]

mainContext.add(logoModifier).add logo
