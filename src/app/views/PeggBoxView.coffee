require './scss/activity.scss'

View = require 'famous/src/core/View'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Scrollview = require 'famous/src/views/Scrollview'

ListItemView = require 'views/ListItemView'
Utils = require 'lib/Utils'

class PeggBoxView extends View
  @DEFAULT_OPTIONS:
    itemDensity: null

  constructor: () ->
    super
    @init()

  init: ->
    @items = []

  load: (data) ->
    @items = data

    surfaces = []
    scrollview = new Scrollview
      size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
    scrollview.sequenceFrom surfaces

    i = 0
    while i < @items.length
      item = new ListItemView @items[i]
      item.on 'scroll', =>
        @_eventOutput.emit 'scroll'
      item.pipe scrollview
      surfaces.push item
      i++



    container = new ContainerSurface
      size: [undefined, undefined]
      properties:
        overflow: "hidden"

    container.add scrollview
    @add container



module.exports = PeggBoxView
