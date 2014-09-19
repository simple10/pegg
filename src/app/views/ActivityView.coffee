require './scss/activity.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
ActivityItemView = require 'views/ActivityItemView'
ActivityStore = require 'stores/ActivityStore'
Constants = require 'constants/PeggConstants'
Utils = require 'lib/Utils'
Modifier = require 'famous/core/Modifier'

class ActivityView extends View

  constructor: () ->
    super
    @items = []
    @initListeners()
    @initSurfaces()

  initListeners: ->
    ActivityStore.on Constants.stores.ACTIVITY_CHANGE, @loadActivity

  initSurfaces: ->
    @activities = []
    @activityScrollview = new Scrollview
      size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
    @activityScrollview.sequenceFrom @activities
    container = new ContainerSurface
      size: [undefined, undefined]
      properties:
        overflow: 'hidden'
    container.add @activityScrollview
    containerMod = new Modifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
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
