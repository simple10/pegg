require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
UserStore = require 'stores/UserStore'
Utility = require 'famous/utilities/Utility'
Scrollview = require 'famous/views/Scrollview'
PeggStatusItemView = require 'views/PeggStatusItemView'
Utils = require 'lib/Utils'
RenderNode = require 'famous/core/RenderNode'
SequentialLayout = require 'famous/views/SequentialLayout'

class PlayBadgesView extends View

  constructor: (options) ->
    super options
    @_sequence = []
    @title = ''
    @pic = ''
    @init()

  init: ->
    sequentialLayout = new SequentialLayout
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
    sequentialLayout.sequenceFrom @_sequence

    picNode = new RenderNode
    @pic = new ImageSurface
      classes: ['status__pegg__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
    picMod = new StateModifier
      align: [0.5, 0.01]
      origin: [0.5, 0]
    picNode.add(picMod).add @pic
    @_sequence.push picNode

    titleNode = new RenderNode
    @title = new Surface
      classes: ['status__pegg__title']
      size: [Utils.getViewportWidth(), 120]
      properties:
        marginTop: '20px'
    titleMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    titleNode.add(@title).add titleMod
    @_sequence.push titleNode

    nextNode = new RenderNode
    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0]
      origin: [0, 0]
    nextNode.add(nextMod).add next
    @_sequence.push nextNode

    shareNode = new RenderNode
    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 1]
    shareNode.add(shareMod).add share
    @_sequence.push shareNode

    next.on 'click', ->
      PlayActions.badgesViewed()

    @add sequentialLayout

    @load()

  load: (data) ->
    console.log 'PlayBadgesView.load.data: ', data
    @title.setContent "Awesome Badge of Awesome"
    @pic.setContent UserStore.getAvatar 'height=150&type=normal&width=150'



module.exports = PlayBadgesView
