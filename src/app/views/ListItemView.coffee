require './scss/peggbox'

View = require 'famous/src/core/View'
Transform = require 'famous/src/core/Transform'
Surface = require 'famous/src/core/Surface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Utils = require 'lib/Utils'

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
      size: [Utils.getViewportWidth(), @options.height]
      content: message
      properties:
        width: Utils.getViewportWidth()
      classes: ['peggbox__item']

    item.pipe @_eventOutput

    item.on 'click', =>
      @_eventOutput.emit 'selectItem', @

    item.on 'mousedown', (options) =>
      @_eventOutput.emit 'scroll', @

    itemModifier = new StateModifier

    @add(itemModifier).add item

module.exports = ListItemView
