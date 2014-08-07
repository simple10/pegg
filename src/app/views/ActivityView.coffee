require './scss/activity.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
ActivityItemView = require 'views/ActivityItemView'
ActivityStore = require 'stores/ActivityStore'
Constants = require 'constants/PeggConstants'
Utils = require 'lib/Utils'

class ActivityView extends View

  constructor: () ->
    super
    @items = []
    @initListeners()
    @initSurfaces()

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
    @add container

  initListeners: ->
    ActivityStore.on Constants.stores.ACTIVITY_CHANGE, @loadActivity

  loadActivity:  =>
    @items = ActivityStore.getActivity()

    for item in @items
      itemView = new ActivityItemView item
      itemView.on 'scroll', =>
        @_eventOutput.emit 'scroll'
      itemView.pipe @activityScrollview
      @activities.push itemView


module.exports = ActivityView
