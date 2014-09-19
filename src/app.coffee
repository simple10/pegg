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

#FastClick = require 'fastclick/lib/fastclick'
#FastClick = require 'famous/inputs/fastclick'
#FastClick.attach document.body

# Facebook
Facebook = require 'Facebook'

# Views
AppView = require 'views/AppView'
FpsMeter = require 'views/FpsMeterView'
LoginView = require 'views/LoginView'
SignupView = require 'views/SignupView'

# Layouts
SignupViewLayout = require 'views/layouts/mobile/SignupViewLayout'
LoginViewLayout = require 'views/layouts/mobile/LoginViewLayout'

# Stores
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'

# Actions
PlayActions = require 'actions/PlayActions'
ActivityActions = require 'actions/ActivityActions'
UserActions = require 'actions/UserActions'
CardActions = require 'actions/CardActions'

# Constants
Constants = require 'constants/PeggConstants'

# Routes
Routes = require 'routes/AppRoutes'

GameFlow = require('config/game').game_flows.default
GameScript = require('config/game').scripts.cosmic_unicorn

Utils = require 'lib/Utils'

Transitionable = require 'famous/transitions/Transitionable'
SpringTransition = require 'famous/transitions/SpringTransition'
#WallTransition = require 'famous/transitions/WallTransition'
#SnapTransition = require 'famous/transitions/SnapTransition'
Transitionable.registerMethod 'spring', SpringTransition

# Chrome maxes out at 60 FPS
Engine.setFPSCap 60


if Utils.getViewportWidth() > 400
  div = document.createElement 'div'
  div.className = 'device'
  iframe = document.createElement 'iframe'
  iframe.src = '/index.html'
  iframe.className = 'iframe'
  div.appendChild iframe
  document.body.appendChild div
else
  # Create the main context
  mainContext = Engine.createContext()

  # Set perspective for 3D effects
  # Lower values make effects more pronounced and extreme
  mainContext.setPerspective 2000

  appView = new AppView
  loginView = new LoginView
  signupView = new SignupView SignupViewLayout
  lightbox = new Lightbox
  #  inOpacity: 1
  #  outOpacity: 0
    inOrigin: [1, -1]
    outOrigin: [0, -1]
    showOrigin: [0.5, 0.5]
    inTransform: Transform.thenMove(Transform.rotateX(0), [0, -window.innerHeight, 0])
    outTransform: Transform.thenMove(Transform.rotateZ(0), [0, window.innerHeight, 0])
    inTransition: { duration: 500, curve: Easing.outCubic }
    outTransition: { duration: 350, curve: Easing.outCubic }
  mainContext.add lightbox

  #Wait a couple cycles for Famo.us to boot up, smoother animations
  Timer.after (->
    pickView()
  ), 20

  pickView = ->
    if UserStore.getLoggedIn()
      lightbox.show appView
      PlayActions.load GameFlow, GameScript
      ActivityActions.load 1
      CardActions.loadCategories()
    else if  AppStateStore.getCurrentPageID() is 'card'
      lightbox.show appView
    else if AppStateStore.getCurrentPageID() is 'login'
      lightbox.show loginView
    else
      lightbox.show signupView
    return

  AppStateStore.on Constants.stores.LOGIN_CHANGE, pickView
  UserStore.on Constants.stores.LOGIN_CHANGE, pickView

  mainContext.add new FpsMeter


