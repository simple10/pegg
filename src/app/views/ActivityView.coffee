require './scss/activity.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
Surface = require 'famous/core/Surface'
ActivityItemView = require 'views/ActivityItemView'
ActivityStore = require 'stores/ActivityStore'
Constants = require 'constants/PeggConstants'
Utils = require 'lib/Utils'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'

class ActivityView extends View

  constructor: () ->
    super
    @items = []
    @initListeners()
    @initSurfaces()

  initListeners: ->
    ActivityStore.on Constants.stores.ACTIVITY_CHANGE, @loadActivity

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
    @items = ActivityStore.getActivity()
    for item in @items
      itemView = new ActivityItemView item
      itemView.on 'scroll', =>
        @_eventOutput.emit 'scroll'
      itemView.pipe @activityScrollview
      @activities.push itemView


module.exports = ActivityView
