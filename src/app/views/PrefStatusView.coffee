
View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

class PrefStatusView extends View

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [@options.width, @options.height]
    unicorn = new ImageSurface
      content: 'images/Unicorn_Cosmic_win.png'
      size: [239, 239]
    unicornMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    container.add(unicornMod).add unicorn

    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.5, .8]
      origin: [0.5, 1]
    container.add(nextMod).add next

    @add container
    next.on 'click', ->
      PlayActions.nextStage()

  load: (data) ->
    # TODO: load status data
    console.log data


module.exports = PrefStatusView
