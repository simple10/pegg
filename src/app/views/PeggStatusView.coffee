
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

class PeggStatusView extends View

  title = ''
  pic = ''
  itemViews = []

  constructor: (options) ->
    super options
    @init()

  init: ->

    @container = new ContainerSurface
      size: [Utils.getViewportWidth(), undefined]

    @itemsScrollView = new Scrollview
      direction: Utility.Direction.Y
      paginated: false
      margin: 300
    @itemsScrollView.sequenceFrom itemViews
    itemsScrollViewMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
    @container.add(itemsScrollViewMod).add @itemsScrollView
    @container.pipe @itemsScrollView
    @add @container

    @picNode = new RenderNode
    pic = new ImageSurface
      classes: ['status__pegg__pic']
      size: [150, 150]
      properties:
        borderRadius: '200px'
    pic.pipe @itemsScrollView
    picMod = new StateModifier
      align: [0.5, 0.01]
      origin: [0.5, 0]
    @picNode.add(picMod).add pic

    @titleNode = new RenderNode
    title = new Surface
      classes: ['status__pegg__title']
      size: [Utils.getViewportWidth(), 120]
      properties:
        marginTop: '20px'
    titleMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    @titleNode.add(title).add titleMod

    @nextNode = new RenderNode
    next = new ImageSurface
      content: 'images/continue_big_text.png'
      size: [60, 120]
    nextMod = new StateModifier
      align: [0.6, 0]
      origin: [0, 0]
    @nextNode.add(nextMod).add next

    @shareNode = new RenderNode
    share = new ImageSurface
      content: 'images/share_big_text.png'
      size: [48, 95]
    shareMod = new StateModifier
      align: [0.2, 0]
      origin: [0, 1]
    @shareNode.add(shareMod).add share

    next.on 'click', ->
      PlayActions.nextStage()

    @load()

  load: (data) ->
    console.log 'PeggStatusView.load.data: ' + data

    itemViews.length = 0
    itemViews.push @picNode
    itemViews.push @titleNode

    if data? and data.stats? and data.stats.length > 0
      peggee = data.stats[0].peggee
      title.setContent "#{peggee.get 'first_name'} #{peggee.get 'last_name'}'s <br/>Top Peggers:"
      pic.setContent "#{peggee.get 'avatar_url'}?height=150&type=normal&width=150"

      for stat in data.stats
        peggItem =  new PeggStatusItemView
        peggItem.load stat
        itemViews.push peggItem

    itemViews.push @nextNode
    itemViews.push @shareNode

    @itemsScrollView.goToPage(0)



module.exports = PeggStatusView
