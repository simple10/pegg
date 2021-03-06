require './scss/activity.scss'

View = require 'famous/src/core/View'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Scrollview = require 'famous/src/views/Scrollview'
Surface = require 'famous/src/core/Surface'
ActivityItemView = require 'views/ActivityItemView'
WeStore = require 'stores/WeStore'
Constants = require 'constants/PeggConstants'
Utils = require 'lib/Utils'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier = require 'famous/src/core/Modifier'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'

class ActivityView extends View

  constructor: () ->
    super
    @items = []
    @initListeners()
    @initSurfaces()

  initListeners: ->
#    WeStore.on Constants.stores.ACTIVITY_CHANGE, @loadActivity

  initSurfaces: ->
    ## LEFT ARROW ##
    leftArrow = new ImageSurface
      size: [46, 31]
      content: '/images/GoBack_Arrow_on@2x.png'
    leftArrowMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 20, 20, 10
    leftArrow.on 'click', =>
      @_eventOutput.emit 'back', 'Home'
    @add(leftArrowMod).add leftArrow

    text = new Surface
      content: 'Activity'
      size: [Utils.getViewportWidth()/2 - 50, 50]
      classes: ["activity__title"]
    textMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0]
      transform: Transform.translate null, 20, null
    @add(textMod).add text

    @activities = []
    @activityScrollview = new Scrollview
      size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
    @activityScrollview.sequenceFrom @activities

    #TODO: make the in transition cool
#    @activityScrollview.outputFrom (offset) ->
#      Transform.multiply(
#        Transform.translate(null, offset, null)
#        Transform.translate(offset, null, null)
#      )

    container = new ContainerSurface
      size: [undefined, Utils.getViewportHeight() - 110]
      properties:
        overflow: 'hidden'
    container.add @activityScrollview
    containerMod = new Modifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
      transform: Transform.translate null, 40, null
    @add(containerMod).add container

  loadActivity:  =>
    @activities.length = 0
    @items = WeStore.getActivity()
    for item in @items
      itemView = new ActivityItemView item
      itemView.on 'scroll', =>
        @_eventOutput.emit 'scroll'
      itemView.pipe @activityScrollview
      @activities.push itemView


module.exports = ActivityView
