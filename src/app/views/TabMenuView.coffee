require './tabmenu'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Timer = require 'famous/utilities/Timer'
_ = require('Parse')._

TabMenuItemView = require 'views/TabMenuItemView'


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
      @addTab
        pageID: @options.model[i].pageID
        title: @options.model[i].title
        icon: @options.model[i].iconUrl
        xOffset: xOffset
        width: window.innerWidth / @options.model.length
        height: @options.tab.height
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
    tabModifier = new StateModifier
      origin: [0, 0]
      align: [params.xOffset, 0]
      transform: Transform.translate 0, params.height, 0
    @tabModifiers.push tabModifier
    @tabs.push tab
    @add(tabModifier).add tab


  showTabs: ->
    transition = @options.tab.transition
    delay = @options.tab.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform Transform.translate(0, 0, 0), transition
        return
      ).bind(this, i), i * delay
      i++

  hideTabs: ->
    transition = @options.tab.transition
    delay = @options.tab.staggerDelay
    i = 0
    while i < @tabModifiers.length
      Timer.setTimeout ((i) ->
        @tabModifiers[i].setTransform Transform.translate(0, @options.tab.height, 0), transition
        return
      ).bind(this, i), i * delay
      i++

  resetTabs: ->
    transition = @options.tab.transition
    i = 0
    while i < @tabModifiers.length
      @tabModifiers[i].setTransform Transform.translate(0, 0, 0), transition
      i++

module.exports = TabMenuView
