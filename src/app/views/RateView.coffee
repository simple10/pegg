
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
PlayActions = require 'actions/PlayActions'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'

class RateView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth
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
        @starModifiers[i].setTransform Transform.translate(0, -window.innerHeight/2+@options.height, 0), @options.transition
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
