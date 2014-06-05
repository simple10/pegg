require './peggbox'

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

    #pic = @options.pic
    message = @options.get "title"
    content = "
      <span>#{message}</span>
    "

    item = new Surface
      size: [window.innerWidth, @options.height]
      content: content
      properties:
        width: window.innerWidth
      classes: ['peggbox__item']

    item.on 'click', =>
      @_eventOutput.emit 'selectItem', @

    item.pipe @_eventOutput

    itemModifier = new StateModifier

    @add(itemModifier).add item


module.exports = ListItemView
