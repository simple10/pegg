require './scss/tabmenu'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Timer = require 'famous/src/utilities/Timer'
_ = require('Parse')._

TabMenuItemView = require 'views/TabMenuItemView'
Utils = require 'lib/Utils'
UserStore = require 'stores/UserStore'
LayoutManager = require 'views/layouts/LayoutManager'


###
# Events:
# selectTabMenuItem {{menuID}}
###
class TabMenuView extends View
  @DEFAULT_OPTIONS:
    model: null

  constructor: (options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'FooterView'

    @init()

  init: ->
    @tabs = []
    @tabModifiers = []
    i = 0
    xOffset = 0
    while i < @options.model.length
#      if i is @options.model.length - 1
#        iconUrl = UserStore.getAvatar 'type=square'
#        properties =
#          borderRadius: "#{@layout.height}px"
#          padding: '4px'
#      else
      iconUrl = @options.model[i].iconUrl
      @addTab
        pageID: @options.model[i].pageID
        title: @options.model[i].title
        icon: iconUrl
        xOffset: xOffset
        width: Utils.getViewportWidth() / @options.model.length
        height: @layout.height
#        properties: properties
      i++
      xOffset += 1/@options.model.length


  addTab: (params) ->
    tab = new TabMenuItemView
      pageID: params.pageID
      title: params.title
      iconUrl: params.icon
      width: params.width
      height: params.height
      xOffset: params.xOffset
      properties: params.properties
    tabModifier = new StateModifier
      origin: [0, 0]
      align: [params.xOffset, 0]
#      transform: Transform.translate 0, params.height, 10
    @tabModifiers.push tabModifier
    @tabs.push tab
    @add(tabModifier).add tab


  showTabs: ->
    transition = @layout.transition
    delay = @layout.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform @layout.transform, transition
        return
      ).bind(this, i), i * delay
      i++

  hideTabs: ->
    transition = @layout.transition
    delay = @layout.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform Transform.translate(0, @layout.height, null), transition
        return
      ).bind(this, i), i * delay
      i++

  bounceTabs: ->
    transition = @layout.transition
    delay = @layout.staggerDelay
    i = 0
    tab = 0
    y = @layout.height
    while i < @tabModifiers.length * 2
      Timer.setTimeout ((i) ->
        @tabModifiers[tab].setTransform Transform.translate(0, y, null), transition
        tab++
        if tab == @tabModifiers.length
          tab = 0
          y = 0
        return
      ).bind(this, i), i * delay
      i++



module.exports = TabMenuView
