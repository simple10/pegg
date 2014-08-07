
require './scss/moods.scss'

View = require 'famous/core/View'
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
    #@init()

  load: (data) ->
    @moods = data

  init: ->
    @grid = new GridLayout
      dimensions: [2,2]
      transition:
        curve: 'easeInOut'
        duration: 800
      gutterSize: [10,10]
    surfaces = []
    @grid.sequenceFrom surfaces
    for i in [0..3]
      surfaces.push new ImageSurface
        content: @moods[i].imageUrl
        size: [Utils.getViewportWidth()/2 - 30, Utils.getViewportWidth()/2 - 40]
        classes: ["#{@cssPrefix}__box"]
    gridMod = new StateModifier
      size: [Utils.getViewportWidth() - 30, Utils.getViewportHeight() - 250]
      origin: [0.5, 0.5]
      align: [0.5, 0.5]
    @add(gridMod).add @grid

  rearrange: ->
    @grid.setOptions
      dimensions: [3, 2]


module.exports = MoodsView
