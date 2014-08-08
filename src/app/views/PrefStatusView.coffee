
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
PlayStore = require 'stores/PlayStore'
Utils = require 'lib/Utils'

class PrefStatusView extends View
  _itemViews: []
  _userName: ''
  _userPic: ''

  constructor: (options) ->
    super options
    @init()

  init: ->
    container = new ContainerSurface
      size: [Utils.getViewportWidth(), Utils.getViewportHeight()]

    @itemsScrollView = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 300
    @itemsScrollView.sequenceFrom @_itemViews
    itemsScrollViewMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]

    userPicNode = new RenderNode
    @_userPic = new ImageSurface
      classes: ['status__preffer__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
    userPicMod = new StateModifier
      align: [0.5, 0.05]
      origin: [0.5, 0]
    userPicNode.add(userPicMod).add @_userPic
    @_itemViews.push userPicNode

    userNameNode = new RenderNode
    @_userName = new Surface
      classes: ['status__preffer__name']
      size: [Utils.getViewportWidth() - 60, 175]
    userNameMod = new StateModifier
      align: [0.5, 0.1]
      origin: [0.5, 0]
    userNameNode.add(userNameMod).add @_userName
    @_itemViews.push userNameNode


    # On load() PrefStatusItemView will be added here in the @_itemViews array

#    i = 0
#    while i < @options.numCards
#      prefStatusItem = new PrefStatusItemView
#      @_itemViews.push prefStatusItem
#      @_statsViews.push prefStatusItem
#      prefStatusItem.pipe @itemsScrollView
#      i++

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
#    @_userName.setContent UserStore.getName 'first'
    @_userName.setContent "What did everyone else choose?"
#    @_userPic.setContent UserStore.getAvatar 'height=150&type=normal&width=150'
    @_userPic.setContent PlayStore.getMessage 'unicorn'

    # Remove all the PrefStatusItemViews
    while @_itemViews.length > 4
      @_itemViews.splice 2, 1

    # Add back a PrefStatusItemViews for every stat
    i = 0
    for own id, stat of data.stats
      prefStatusItem = new PrefStatusItemView
      prefStatusItem.load stat
      prefStatusItem.pipe @itemsScrollView
      @_itemViews.splice i + 2, 0, prefStatusItem
      i++

    @itemsScrollView.goToPage(0)

#
#
#    fixedItems = @_itemViews.length - @options.numCards
#    while @_itemViews.length > i + fixedItems
#      # remove the unnecessary PrefStatusItemViews.
#      # skip the first 3 items in the array
#      @_itemViews.splice i + 2, 1
#      @_statsViews.pop()





module.exports = PrefStatusView
