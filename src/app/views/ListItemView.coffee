require './scss/peggbox'

View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
StateModifier = require 'famous/modifiers/StateModifier'

class ListItemView extends View
  @DEFAULT_OPTIONS:
    itemID: null
    message: null
    pic: null
    height: 100

  constructor: (options) ->
    super
    @init()

  init: ->
    @build()

  build: ->

    #pic = @options.get "pic"
    message = @options.get "message"

    item = new Surface
      size: [window.innerWidth, @options.height]
      content: message
      properties:
        width: window.innerWidth
      classes: ['peggbox__item']

    item.pipe @_eventOutput

    item.on 'click', =>
      @_eventOutput.emit 'selectItem', @

    item.on 'mousedown', (options) =>
      @_eventOutput.emit 'scroll', @

    itemModifier = new StateModifier

    @add(itemModifier).add item

module.exports = ListItemView
