
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'
PlayStore = require 'stores/PlayStore'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'

class DoneStatusView extends View

  pic = ''
  title = ''

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
      properties:
        overflow: 'hidden'
#    pic = new ImageSurface
#      classes: ['status__done__pic']
#      size: [150, 150]
#      properties:
#        borderRadius: '200px'
#    picMod = new StateModifier
#      align: [0.5, 0.02]
#      origin: [0.5, 0]
#    container.add(picMod).add pic
    title = new Surface
      classes: ['status__done__title']
      size: [Utils.getViewportWidth()-20, 200]
    titleMod = new StateModifier
      align: [0.5, 0.28]
      origin: [0.5, 0]
    container.add(titleMod).add title

    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0.91]
      origin: [0, 1]
    container.add(nextMod).add next

    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0.9]
      origin: [0, 1]
    container.add(shareMod).add share

    @add container
    next.on 'click', ->
      PlayActions.nextStage()

  load: (data) ->
#    if data.done.length > 0
    title.setContent PlayStore.getMessage data.type




module.exports = DoneStatusView
