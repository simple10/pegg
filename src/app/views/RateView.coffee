
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
    staggerDelay: 35
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
        size: [ @options.width/spacing, @options.height ]
        content: "images/star_white_256.png"
      starMod = new StateModifier
        align: [1/spacing*i,1.5]
        origin: [0,1]
      star.on 'click', (i)->
        PlayActions.rate 'cardID', "#{i}"
      @starModifiers.push starMod
      @stars.push star
      @mainNode.add(starMod).add star
      i++

  showStars: ->
    transition = @options.transition
    delay = @options.staggerDelay
    i = 0
    while i < @starModifiers.length
      Timer.setTimeout ((i) ->
        @starModifiers[i].setTransform Transform.translate(0, -window.innerHeight/2+@options.height, 0), transition
        return
      ).bind(this, i), i * delay
      i++

  pickStar: (pos) =>
    delay = @options.staggerDelay
    i = 0
    while i < pos
      console.log i + " " + pos
      Timer.setTimeout ((i) ->
        @stars[i].setContent "images/star_gold_256.png"
        return
      ).bind(this, i), i * delay
      i++

module.exports = RateView
