
require './scss/moods.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Modifier = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
GridLayout = require 'famous/views/GridLayout'
Utils = require 'lib/Utils'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
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

    @_addDashboardItem 0, 'images/Unicorn_Rookie1@2x.png' , 'Activity'
    @_addDashboardItem 0, 'images/Unicorn_Cosmic1@2x.png' , 'Challenges'
    @_addDashboardItem 0, 'images/Unicorn_Glowing1@2x.png' , 'Stats'
    @_addDashboardItem 0, 'images/Unicorn_Fire1@2x.png' , 'Peggbox'


  _addDashboardItem: (id, url, page) =>
    container = new ContainerSurface
      size: [Utils.getViewportWidth()/2, Utils.getViewportWidth()/2]
      classes: ["#{@cssPrefix}__box"]
    container.on 'click', =>
      @_eventOutput.emit 'pageSelect', page

    image = new ImageSurface
      content: url
      size: [Utils.getViewportWidth()/2 - 80, Utils.getViewportWidth()/2 - 80]
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
      align: [0.5, 0.9]
    container.add(textMod).add text

    @surfaces.push container


  rearrange: ->
    @grid.setOptions
      dimensions: [3, 2]


module.exports = HomeMenuView
