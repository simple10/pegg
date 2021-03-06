
View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
PlayActions = require 'actions/PlayActions'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
Utils = require 'lib/Utils'

class RateView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth()
    height: 50
    scale: 5
    staggerDelay: 50
    transition:
      duration: 400
      curve: 'easeOut'

  constructor: (options) ->
    super options
    @init()

  init: ->
    @state = new StateModifier
    @mainNode = @add @state
    @starModifiers = []
    @stars = []
    i = 1
    spacing = @options.scale + 2
    while i <= @options.scale
      star = new ImageSurface
        size: [ @options.height, @options.height ]
        content: "images/sun__grey_50px.png"
      starMod = new StateModifier
        align: [1/spacing*i,1.5]
        origin: [0,1]
      # numStars will equal i thanks to bind
      star.on 'click', ((numStars) ->
        @pickStar numStars
        Timer.setTimeout ((pos) ->
          PlayActions.rate pos
          @resetStars()
        ).bind(@, numStars), numStars * @options.staggerDelay
      ).bind @, i
      @starModifiers.push starMod
      @stars.push star
      @mainNode.add(starMod).add star
      i++

  showStars: ->
    i = 0
    while i < @starModifiers.length
      Timer.setTimeout ((i) ->
        @starModifiers[i].setTransform Transform.translate(0, -Utils.getViewportHeight()/2+@options.height, 0), @options.transition
        return
      ).bind(this, i), i * @options.staggerDelay
      i++

  resetStars: ->
    i = 0
    while i < @starModifiers.length
      Timer.setTimeout ((i) ->
        @stars[i].setContent "images/sun__grey_50px.png"
        @starModifiers[i].setTransform Transform.translate(0, 0, 0), @options.transition
        return
      ).bind(this, i), i * @options.staggerDelay
      i++

  pickStar: (pos) =>
    i = 0
    while i < pos
      Timer.setTimeout ((i) ->
        @stars[i].setContent "images/sun_50px.png"
        return
      ).bind(@, i), i *  @options.staggerDelay
      i++




module.exports = RateView
