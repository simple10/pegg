require './scss/status.scss'

# Famo.us
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Utility = require 'famous/src/utilities/Utility'
Scrollview = require 'famous/src/views/Scrollview'
Utils = require 'lib/Utils'
RenderNode = require 'famous/src/core/RenderNode'

# Pegg
Constants = require 'constants/PeggConstants'
UserStore = require 'stores/UserStore'
WeStore = require 'stores/WeStore'

class InsightsView extends View

  constructor: (options) ->
    super options
    @initListeners()
    @initRenderables()


  initListeners: ->
    WeStore.on Constants.stores.INSIGHTS_LOADED, @load

  initRenderables: ->


  load: ->
    console.log 'InsightsView.load.data: ' + JSON.stringify WeStore.getInsights()




module.exports = InsightsView
