require './scss/activity.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
ListItemView = require 'views/ListItemView'
ActivityStore = require 'stores/ActivityStore'
Constants = require 'constants/PeggConstants'

class ActivityView extends View

  constructor: () ->
    super
    @items = []
    @initListeners()

  initListeners: ->
    ActivityStore.on Constants.stores.ACTIVITY_CHANGE, @loadActivity

  loadActivity:  =>
    @items = ActivityStore.getActivity()
    activities = []
    activityScrollview = new Scrollview
      size: [window.innerWidth, window.innerHeight]
    activityScrollview.sequenceFrom activities

    for item in @items
      itemView = new ListItemView item
      itemView.on 'scroll', =>
        @_eventOutput.emit 'scroll'
      itemView.pipe activityScrollview
      activities.push itemView

    container = new ContainerSurface
      size: [undefined, undefined]
      properties:
        overflow: "hidden"
    container.add activityScrollview
    @add container

module.exports = ActivityView
