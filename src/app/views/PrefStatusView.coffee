
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
RenderNode = require 'famous/core/RenderNode'

class PrefStatusView extends View
  _itemViews: []
  _statsViews: []
  _userName: ''
  _userPhoto: ''

  constructor: (options) ->
    super options
    @_userName = UserStore.getName 'first'
    @_userPhoto = UserStore.getAvatar 'height=150&type=normal&width=150'
    @init()

  init: ->
    container = new ContainerSurface
      size: [window.innerWidth, window.innerHeight]

    @itemsScrollView = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 300
    @itemsScrollView.sequenceFrom @_itemViews
    itemsScrollViewMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]

    userPicNode = new RenderNode
    userPic = new ImageSurface
      classes: ['status__preffer__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
      content: @_userPhoto
    userPicMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    userPicNode.add(userPicMod).add userPic
    @_itemViews.push userPicNode

    userNameNode = new RenderNode
    userName = new Surface
      classes: ['status__preffer__name']
      size: [window.innerWidth, 50]
      content: @_userName
    userNameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    userNameNode.add(userNameMod).add userName
    @_itemViews.push userNameNode

    i = 0
    while i < 3
      prefStatusItem = new PrefStatusItemView
      @_itemViews.push prefStatusItem
      @_statsViews.push prefStatusItem
      prefStatusItem.pipe @itemsScrollView
      i++

    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0]
      origin: [0, 0]
    nextNode = new RenderNode
    nextNode.add(nextMod).add next
    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 1]
    shareNode = new RenderNode
    shareNode.add(shareMod).add share

    @_itemViews.push nextNode
    @_itemViews.push shareNode

    container.add(itemsScrollViewMod).add @itemsScrollView

    @add container
    next.on 'click', ->
      PlayActions.nextStage()


  load: (data) ->
    i = 0
    for own id, stat of data.stats
      @_statsViews[i].load stat
      i++
    @itemsScrollView.goToPage(0)



module.exports = PrefStatusView
