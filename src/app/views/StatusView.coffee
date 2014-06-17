
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'

class StatusView extends View
  @DEFAULT_OPTIONS:
    transition:
      duration: 400
      curve: 'easeOut'

  constructor: (steps, options) ->
    super options
    @init()

  init: ->
    statusMod = new StateModifier
    @mainNode = @add statusMod
    @unicorn = new ImageSurface
      content: "images/Unicorn_Cosmic_win.png"
      size: [239, 239]
    @unicornMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    @mainNode.add(@unicornMod).add @unicorn

    next = new ImageSurface
      content: "images/continue_big_text.png"
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.5, .8]
      origin: [0.5, 1]
    @mainNode.add(nextMod).add next

    next.on "click", ->
      PlayActions.continue()



module.exports = StatusView
