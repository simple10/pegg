
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

class PeggStatusView extends View

  userPic = ''
  userName = ''
  itemViews = []

  constructor: (options) ->
    super options
    @init()

  init: ->
    userPic = new ImageSurface
      classes: ['status__peggee__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
    userPicMod = new StateModifier
      align: [0.5, 0.02]
      origin: [0.5, 0]
    @add(userPicMod).add userPic
    userName = new Surface
      classes: ['status__peggee__name']
      size: [Utils.getViewportWidth(), 110]
    userNameMod = new StateModifier
      align: [0.5, 0.32]
      origin: [0.5, 0]
    @add(userNameMod).add userName

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
      itemViews.push new PeggStatusItemView
      i++
    @add(itemsScrollViewMod).add itemsScrollView

    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0]
      origin: [0, 0]
    @add(nextMod).add next
    next.pipe itemsScrollView

    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 0]
    @add(shareMod).add share
    share.pipe itemsScrollView

    next.on 'click', ->
      PlayActions.nextStage()

  load: (data) ->
    console.log data
    if data.stats.length > 0
      peggee = data.stats[0].peggee
      userName.setContent "#{peggee.get 'first_name'} #{peggee.get 'last_name'}"
      userPic.setContent "#{peggee.get 'avatar_url'}?height=150&type=normal&width=150"

      i = 0
      for stat in data.stats
        if !itemViews[i]?
          itemViews.push new PeggStatusItemView
        itemViews[i].load stat
        i++

      while itemViews.length > data.stats.length
        itemViews.pop()



module.exports = PeggStatusView
