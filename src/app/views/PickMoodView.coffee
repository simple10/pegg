
require './scss/moods.scss'

View = require 'famous/core/View'
RenderNode = require 'famous/core/RenderNode'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
GridLayout = require 'famous/views/GridLayout'
Utils = require 'lib/Utils'

class MoodsView extends View
  cssPrefix: 'moods'

  @DEFAULT_OPTIONS:
    cols: 2

  constructor: ->
    super
    @init()

  init: ->
    @grid = new GridLayout
      dimensions: [2,2]
#      transition:
#        curve: 'easeInOut'
#        duration: 800
      gutterSize: [2,2]
    @surfaces = []
    @grid.sequenceFrom @surfaces
    gridMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
    @add(gridMod).add @grid


  load: (data) ->
    moods = data.moods
    for i in [0..3]
      @_addMood moods[i].get('iconUrl'), moods[i].get('name')

  _addMood: (url, text) ->
    moodNode = new RenderNode
      size: [Utils.getViewportWidth()/2 - 80, Utils.getViewportWidth()/2 - 80]
      classes: ["#{@cssPrefix}__box"]
    moodImage = new ImageSurface
      content: url
      size: [Utils.getViewportWidth()/2 - 80, Utils.getViewportWidth()/2 - 80]
      classes: ["#{@cssPrefix}__box__image"]
    moodImageMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
    moodNode.add(moodImageMod).add moodImage
    moodText = new Surface
      content: text
      size: [Utils.getViewportWidth()/2 - 50, 50]
      classes: ["#{@cssPrefix}__box__text"]
    moodTextMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 1]
    moodNode.add(moodTextMod).add moodText
    @surfaces.push moodNode


  rearrange: ->
    @grid.setOptions
      dimensions: [3, 2]


module.exports = MoodsView
