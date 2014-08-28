
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
  _title: ''
  _userPic: ''

  constructor: (options) ->
    super options
    @init()

  init: ->
    @itemsScrollView = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 300
    @itemsScrollView.sequenceFrom @_itemViews
    itemsScrollViewMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
    @add(itemsScrollViewMod).add @itemsScrollView

#    userPicNode = new RenderNode
#    @_userPic = new ImageSurface
#      classes: ['status__preffer__pic']
#      size: [150, 150]
#      properties:
#        borderRadius: '200px'
#    userPicMod = new StateModifier
#      align: [0.5, 0.05]
#      origin: [0.5, 0]
#    userPicNode.add(userPicMod).add @_userPic
#    @_itemViews.push userPicNode

    @titleNode = new RenderNode
    @_title = new Surface
      classes: ['status__pref__title']
      size: [Utils.getViewportWidth() - 60, 200]
    titleMod = new StateModifier
      align: [0.5, 0.1]
      origin: [0.5, 0]
    @titleNode.add(titleMod).add @_title
    @_title.pipe @itemsScrollView


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
    @nextNode = new RenderNode
    @nextNode.add(nextMod).add next
    next.pipe @itemsScrollView

    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 1]
    @shareNode = new RenderNode
    @shareNode.add(shareMod).add share
    share.pipe @itemsScrollView

    next.on 'click', ->
      PlayActions.nextStage()

    @load()

  load: (data) ->
#    @_title.setContent UserStore.getName 'first'
    @_title.setContent PlayStore.getMessage 'pref_status' if data?
#    @_userPic.setContent UserStore.getAvatar 'height=150&type=normal&width=150'
#    @_userPic.setContent PlayStore.getMessage 'unicorn'

    # Remove all the items and repopulate
    @_itemViews.length = 0

    # Add the title
    @_itemViews.push @titleNode

    # Add a PrefStatusItemViews for every stat
    for own id, stat of data?.stats
      prefStatusItem = new PrefStatusItemView
      prefStatusItem.load stat
      prefStatusItem.pipe @itemsScrollView
      @_itemViews.push prefStatusItem

    # Add the buttons
    @_itemViews.push @nextNode
    @_itemViews.push @shareNode

    # Reset scroll view to top
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
