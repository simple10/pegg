require './scss/status.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
UserStore = require 'stores/UserStore'
Utility = require 'famous/src/utilities/Utility'
Scrollview = require 'famous/src/views/Scrollview'
PeggStatusItemView = require 'views/PeggStatusItemView'
Utils = require 'lib/Utils'
RenderNode = require 'famous/src/core/RenderNode'
SequentialLayout = require 'famous/src/views/SequentialLayout'

class PlayBadgesView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth()
    height: Utils.getViewportHeight() - 50
    origin: [0, 1]
    align: [0, 1]

  constructor: (options) ->
    super options
    @_sequence = []
    @scrollview = null
    @init()

  init: ->
    @scrollview = new Scrollview
      size: [Utils.getViewportWidth(), Utils.getViewportHeight() - 50]
      align: [0, 1]
      origin: [0, 1]

    @scrollview.sequenceFrom(@_sequence)

    container = new ContainerSurface
      size: [Utils.getViewportWidth(), Utils.getViewportHeight() - 50]
      align: [0, 1]
      origin: [0, 1]
    container.add @scrollview
    container.pipe @scrollview
    @add container

    @titleNode = new RenderNode
    @title = new Surface
      classes: ['status__pegg__title']
      properties:
        marginTop: '50px'
      size: [Utils.getViewportWidth(), 160]
    titleMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    @titleNode.add(@title).add titleMod
    @title.pipe @scrollview

    @nextNode = new RenderNode
    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0]
      origin: [0, 1]
    next.pipe @scrollview
    @nextNode.add(nextMod).add next

    @shareNode = new RenderNode
    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 0]
    share.pipe @scrollview
    @shareNode.add(shareMod).add share

    next.on 'click', =>
      PlayActions.badgesViewed(@badge)

    @load()

  load: (badge) ->
    return unless badge?
    @badge = badge
    @_sequence.length = 0

#    someNewBadges = "a new badge"
#    if badges.length > 1
#      someNewBadges = "new badges"
    @title.setContent "Congratulations! <br/> You've leveled up, unicorn."
    @_sequence.push @titleNode

#    for badge in (badges or [])
    picNode = new RenderNode
    pic = new ImageSurface
      classes: ['status__pegg__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
    picMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    picNode.add(picMod).add pic
    pic.pipe @scrollview
    pic.setContent @badge.image
    @_sequence.push picNode

    nameNode = new RenderNode
    name = new Surface
      classes: ['status__pegg__title']
      size: [Utils.getViewportWidth(), 120]
      properties:
        marginTop: '20px'
    nameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    nameNode.add(name).add nameMod
    name.pipe @scrollview
    name.setContent @badge.name
    @_sequence.push nameNode

    @_sequence.push @shareNode
    @_sequence.push @nextNode
    @scrollview.goToPage(0)


module.exports = PlayBadgesView
