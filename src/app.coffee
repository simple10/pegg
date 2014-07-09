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
SignupView = require 'views/SignupView'

# Layouts
SignupViewLayout = require 'views/layouts/iPhone5/SignupViewLayout'
LoginViewLayout = require 'views/layouts/iPhone5/LoginViewLayout'

# Stores
UserStore = require 'stores/UserStore'
AppStateStore = require 'stores/AppStateStore'

# Actions
UserActions = require 'actions/UserActions'
MenuActions = require 'actions/MenuActions'
PlayActions = require 'actions/PlayActions'

# Constants
Constants = require 'constants/PeggConstants'

# Routes
Routes = require 'routes/AppRoutes'


# Create the main context
mainContext = Engine.createContext()

# Chrome maxes out at 60 FPS
Engine.setFPSCap 60


# Set perspective for 3D effects
# Lower values make effects more pronounced and extreme
mainContext.setPerspective 2000

appView = new AppView
loginView = new LoginView LoginViewLayout
signupView = new SignupView SignupViewLayout
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

#Wait a couple cycles for Famo.us to boot up, smoother animations
Timer.after (->
  pickView()
), 20

pickView = ->
  if UserStore.getLoggedIn()
    lightbox.show appView
    PlayActions.load()
  else if AppStateStore.getCurrentPageID() is 'login'
    lightbox.show loginView
  else
    lightbox.show signupView

#AppStateStore.on Constants.stores.CHANGE, pickView
UserStore.on Constants.stores.CHANGE, pickView

mainContext.add new FpsMeter


