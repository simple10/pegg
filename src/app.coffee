# CSS
require 'famous/core/famous.css'

# Polyfills
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'

# Famous
Engine = require 'famous/core/Engine'

# Views
AppView = require 'views/AppView'
FpsMeter = require 'views/FpsMeterView'

# Create the main context
mainContext = Engine.createContext()

# Chrome maxes out at 60 FPS
Engine.setFPSCap 60

# Set perspective for 3D effects
# Lower values make effects more pronounced and extreme
mainContext.setPerspective 2000

mainContext.add new AppView
mainContext.add new FpsMeter

