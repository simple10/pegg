
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

class MoodsView extends View
  cssPrefix: 'moods'

  @DEFAULT_OPTIONS:
    cols: 2

  constructor: ->
    super
    @init()

  init: ->

    @day = new Surface
      size: [Utils.getViewportWidth(), 100]
      classes: ["#{@cssPrefix}__welcome", "#{@cssPrefix}__text--yellow"]
    dayMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0.05]
    @add(dayMod).add @day

    title = new Surface
      size: [Utils.getViewportWidth(), 100]
      content: 'How are you <br/> feeling?'
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

#    passMood = new Surface
#      content: "Not in the mood? <span class='#{@cssPrefix}__text--yellow'>Play random</span>"
#      size: [Utils.getViewportWidth() - 20, 30]
#      classes: ["#{@cssPrefix}__pass"]
#    passMoodMod = new Modifier
#      origin: [0, 1]
#      align: [0.05, 0.9]
#    container.add(passMoodMod).add passMood

  load: (moods) ->
    moodIndex = []
    random = Math.floor(Math.random() * moods.length)
    moodIndex.push random
    # load 4 unique moods
    for i in [0..3]
      while moodIndex.indexOf(random) isnt -1
        random = Math.floor(Math.random() * moods.length)
      moodIndex.push random
      @_addMood moods[random].id, moods[random].get('iconUrl'), moods[random].get('name')

    # load today's day message
    days = [ 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    today = new Date()
    day = today.getDay()
    @day.setContent "Happy #{days[day]}!"


  _addMood: (id, url, text) ->
    moodContainer = new ContainerSurface
      size: [Utils.getViewportWidth()/2, Utils.getViewportWidth()/2]
      classes: ["#{@cssPrefix}__box"]
    moodContainer.on 'click', =>
      PlayActions.mood text, id, url

    moodImage = new ImageSurface
      content: url
      size: [Utils.getViewportWidth()/2 - 80, Utils.getViewportWidth()/2 - 80]
      classes: ["#{@cssPrefix}__box__image"]
    moodImageMod = new Modifier
      origin: [0.5, 0]
      align: [0.5, 0]
    moodContainer.add(moodImageMod).add moodImage

    moodText = new Surface
      content: text
      size: [Utils.getViewportWidth()/2 - 50, 50]
      classes: ["#{@cssPrefix}__box__text"]
    moodTextMod = new Modifier
      origin: [0.5, 0.9]
      align: [0.5, 0.9]
    moodContainer.add(moodTextMod).add moodText

    @surfaces.push moodContainer


  rearrange: ->
    @grid.setOptions
      dimensions: [3, 2]


module.exports = MoodsView
