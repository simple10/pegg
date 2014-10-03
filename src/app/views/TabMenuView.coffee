require './scss/tabmenu'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
_ = require('Parse')._

TabMenuItemView = require 'views/TabMenuItemView'
Utils = require 'lib/Utils'
UserStore = require 'stores/UserStore'


###
# Events:
# selectTabMenuItem {{menuID}}
###
class TabMenuView extends View
  @DEFAULT_OPTIONS:
    tab:
      height: 60
      staggerDelay: 35
      transition:
        duration: 400
        curve: 'easeOut'
    model: null


  constructor: (options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @init()

  init: ->
    @tabs = []
    @tabModifiers = []
    i = 0
    xOffset = 0
    while i < @options.model.length
      if i is @options.model.length - 1
        iconUrl = UserStore.getAvatar 'type=square'
        properties =
          borderRadius: "#{@options.tab.height}px"
          padding: '4px'
      else
        iconUrl = @options.model[i].iconUrl
      @addTab
        pageID: @options.model[i].pageID
        title: @options.model[i].title
        icon: iconUrl
        xOffset: xOffset
        width: Utils.getViewportWidth() / @options.model.length
        height: @options.tab.height
        properties: properties
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
      transform: Transform.translate 0, params.height, 5
    @tabModifiers.push tabModifier
    @tabs.push tab
    @add(tabModifier).add tab


  showTabs: ->
    transition = @options.tab.transition
    delay = @options.tab.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform Transform.translate(0, 0, 19), transition
        return
      ).bind(this, i), i * delay
      i++

  hideTabs: ->
    transition = @options.tab.transition
    delay = @options.tab.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform Transform.translate(0, @options.tab.height, 19), transition
        return
      ).bind(this, i), i * delay
      i++

  bounceTabs: ->
    transition = @options.tab.transition
    delay = @options.tab.staggerDelay
    i = 0
    tab = 0
    y = @options.tab.height
    while i < @tabModifiers.length * 2
      Timer.setTimeout ((i) ->
        @tabModifiers[tab].setTransform Transform.translate(0, y, 19), transition
        tab++
        if tab == @tabModifiers.length
          tab = 0
          y = 0
        return
      ).bind(this, i), i * delay
      i++



module.exports = TabMenuView
