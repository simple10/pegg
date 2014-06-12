# CSS
require 'famous/core/famous.css'

# Polyfills
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'

# Famous
Engine = require 'famous/core/Engine'
Lightbox = require 'famous/views/Lightbox'
Timer = require 'famous/utilities/Timer'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'

# Facebook
Facebook = require 'Facebook'

# Views
AppView = require 'views/AppView'
FpsMeter = require 'views/FpsMeterView'
LoginView = require 'views/LoginView'

# Stores
UserStore = require 'stores/UserStore'

# Actions
UserActions = require 'actions/UserActions'

# Constants
Constants = require 'constants/PeggConstants'


# Create the main context
mainContext = Engine.createContext()

# Chrome maxes out at 60 FPS
Engine.setFPSCap 60


# Set perspective for 3D effects
# Lower values make effects more pronounced and extreme
mainContext.setPerspective 2000

appView = new AppView
loginView = new LoginView
lightbox = new Lightbox
  inOpacity: 1
  outOpacity: 0
  inOrigin: [.5, 1]
  outOrigin: [0, 0]
  showOrigin: [0.5, 0.5]
  inTransform: Transform.thenMove(Transform.rotateX(1), [0, window.innerHeight, -300])
  outTransform: Transform.thenMove(Transform.rotateZ(0.7), [0, -window.innerHeight, -1000])
  inTransition: { duration: 1000, curve: Easing.outExpo }
  outTransition: { duration: 500, curve: Easing.inCubic }
mainContext.add lightbox

pickView = ->
  if UserStore.getLoggedIn()
    lightbox.show appView
  else
    lightbox.show loginView

#Wait a couple cycles for Famo.us to boot up, smoother animations
Timer.after (->
  pickView()
), 20

UserStore.on Constants.stores.CHANGE, ->
  pickView()

mainContext.add new FpsMeter


