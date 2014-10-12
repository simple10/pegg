
require './scss/status.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
PlayActions = require 'actions/PlayActions'
PlayStore = require 'stores/PlayStore'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'

class DoneStatusView extends View

  pic = ''
  title = ''

  constructor: (options) ->
    super options
    @init()

  init: ->
#    pic = new ImageSurface
#      classes: ['status__done__pic']
#      size: [150, 150]
#      properties:
#        borderRadius: '200px'
#    picMod = new StateModifier
#      align: [0.5, 0.02]
#      origin: [0.5, 0]
#    @add(picMod).add pic
    title = new Surface
      classes: ['status__done__title']
      size: [Utils.getViewportWidth()-20, 100]
      content: 'Round Complete.'
    titleMod = new StateModifier
      align: [0.5, 0.28]
      origin: [0.5, 0]
    @add(titleMod).add title

    @okButton = new Surface
      content: 'Play Again!'
      classes: ["status__done__button", "status__done__button--blue"]
      properties:
        lineHeight: '50px'
    @okButtonMod = new StateModifier
      size: [Utils.getViewportWidth() - 50, 50]
#      transform:
    @okButton.on 'click', =>
      PlayActions.load()
    @add(@okButtonMod).add @okButton


#    next = new ImageSurface
#      content: 'images/continue_big_text.png'
#      size: [60, 120]
#    nextMod = new StateModifier
#      align: [0.6, 0.91]
#      origin: [0, 1]
#    @add(nextMod).add next
#
#    share = new ImageSurface
#      content: 'images/share_big_text.png'
#      size: [48, 95]
#    shareMod = new StateModifier
#      align: [0.2, 0.9]
#      origin: [0, 1]
#    @add(shareMod).add share
#
#    next.on 'click', ->
#      PlayActions.nextPage()

  load: (data) ->
#    if data.done.length > 0
#    title.setContent PlayStore.getMessage data.type




module.exports = DoneStatusView
