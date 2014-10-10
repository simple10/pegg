
require './scss/moods.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Modifier = require 'famous/src/core/Modifier'
Transform = require 'famous/src/core/Transform'
Easing = require 'famous/src/transitions/Easing'
GridLayout = require 'famous/src/views/GridLayout'
Utils = require 'lib/Utils'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
PlayActions = require 'actions/PlayActions'
TypeView = require 'views/TypeView'

class HomeMenuView extends View
  cssPrefix: 'moods'

  @DEFAULT_OPTIONS:
    cols: 2

  constructor: ->
    super
    @init()

  init: ->

#    @type = new TypeView
#      size: [100, 50]
#      classes: ['home__type']
#      origin: [0.5, 0.5]
#      align: [0.5, 0.5]
#    @add @type

    days = [ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    today = new Date()
    day = today.getDay()
    @day = new Surface
      size: [Utils.getViewportWidth(), 100]
      classes: ["#{@cssPrefix}__welcome", "#{@cssPrefix}__text--yellow"]
      content: "Happy #{days[day]}!"
    dayMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0.05]
    @add(dayMod).add @day

    title = new Surface
      size: [Utils.getViewportWidth(), 100]
      content: 'DASHBOARD'
      classes: ["#{@cssPrefix}__title"]
    titleMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0.1]
    @add(titleMod).add title

    @grid = new GridLayout
      cellSize: [Utils.getViewportWidth()/2 - 10, Utils.getViewportWidth()/2 - 10]
      dimensions: [2,2]
      transition:
        curve: 'easeInOut'
        duration: 800
      gutterSize: [0, 0]
    @surfaces = []
    @grid.sequenceFrom @surfaces
    gridMod = new StateModifier
      size: [Utils.getViewportWidth(), Utils.getViewportWidth()]
      origin: [0.5, 0]
      align: [0.5, 0.3]
    @add(gridMod).add @grid

    @_addDashboardItem 0, 'images/Deck-Red.svg' , 'Activity'
    @_addDashboardItem 0, 'images/Deck-Blue.svg' , 'Challenges'
    @_addDashboardItem 0, 'images/Deck-Yellow.svg' , 'Stats'
    @_addDashboardItem 0, 'images/Deck-Green.svg' , 'Peggbox'


  _addDashboardItem: (id, url, page) =>
    container = new ContainerSurface
      size: [Utils.getViewportWidth()/2, Utils.getViewportWidth()/2]
      classes: ["#{@cssPrefix}__box"]
    container.on 'click', =>
      @_eventOutput.emit 'pageSelect', page

    image = new ImageSurface
      content: url
      size: [Utils.getViewportWidth()/2 - 65, Utils.getViewportWidth()/2 - 65]
      classes: ["#{@cssPrefix}__box__image"]
    imageMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0]
    container.add(imageMod).add image

    text = new Surface
      content: page
      size: [Utils.getViewportWidth()/2 - 50, 50]
      classes: ["#{@cssPrefix}__box__text"]
    textMod = new Modifier
      origin: [0.5, 0.9]
      align: [0.5, 0.94]
    container.add(textMod).add text

    @surfaces.push container


  rearrange: ->
    @grid.setOptions
      dimensions: [3, 2]


module.exports = HomeMenuView
