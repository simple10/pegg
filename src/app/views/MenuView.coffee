View = require 'famous/core/View'
Surface = require 'famous/core/Surface'


class MenuView extends View
  constructor: ->
    super
    @background = new Surface
      size: [280, undefined]
      content: 'MENU!!!'
    @add @background
    @background.on 'click', =>
      @_eventOutput.emit 'toggleMenu'


module.exports = MenuView
