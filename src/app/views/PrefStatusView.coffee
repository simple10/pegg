
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
PlayActions = require 'actions/PlayActions'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
UserStore = require 'stores/UserStore'
Utility = require 'famous/utilities/Utility'
PrefStatusItemView = require 'views/PrefStatusItemView'

class PrefStatusView extends View

  itemViews = []

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [window.innerWidth, window.innerHeight]
      properties:
        overflow: 'hidden'
    userPic = new ImageSurface
      classes: ['status__preffer__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
      content: UserStore.getAvatar 'height=150&type=normal&width=150'
    userPicMod = new StateModifier
      align: [0.5, 0.02]
      origin: [0.5, 0]
    container.add(userPicMod).add userPic
    userName = new Surface
      classes: ['status__preffer__name']
      size: [window.innerWidth, 50]
      content: UserStore.getUser().get 'first_name'
    userNameMod = new StateModifier
      align: [0.5, 0.28]
      origin: [0.5, 0]
    container.add(userNameMod).add userName

    itemsScrollView = new Scrollview
    direction: Utility.Direction.Y
    paginated: true
    margin: 300
    itemsScrollView.sequenceFrom itemViews
    itemsScrollViewMod = new StateModifier
      align: [0, 0.4]
      origin: [0, 0]
    i = 0
    while i < 4
      itemViews.push new PrefStatusItemView
      i++
    container.add(itemsScrollViewMod).add itemsScrollView

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
    for own id, card of data.stats.cards
      console.log id, card

    for own id, card of data.played
      console.log id, card



module.exports = PrefStatusView
