View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Transform = require 'famous/core/Transform'
RenderNode = require 'famous/core/RenderNode'

Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
ReviewStore = require 'stores/ReviewStore'
LayoutManager = require 'views/layouts/LayoutManager'

class ReviewNavView extends View
  @DEFAULT_OPTIONS:
    cardType: 'review'
  
  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayNavView'

    @initSurfaces()
    @initEvents()

  setOptions: (options) => 
    @_optionsManager.patch(options);

    # update the card message
    @message.setContent ReviewStore.getMessage()


  initSurfaces: =>

    ## Main View Modifier ##
    @mainMod = new StateModifier
      size: @layout.wrapper.size
      align: @layout.wrapper.align
      origin: @layout.wrapper.origin

    ## LEFT ARROW ##
    @leftArrow = new ImageSurface
      size: @layout.leftArrow.size
      content: '/images/left-arrow.png'
      classes: @layout.leftArrow.classes
    @leftArrowMod = new StateModifier
      align: @layout.leftArrow.align
      origin: @layout.leftArrow.origin

    ## MESSAGE ##
    @message = new Surface
      size: @layout.message.size
      content: 'Generic message'
      classes: @layout.message.classes
    @messageMod = new StateModifier
      align: @layout.message.align
      origin: @layout.message.origin
      transform: @layout.message.transform

    # Attach modifiers and surfaces to the view
    @node = @add @mainMod
    @node.add(@leftArrowMod).add @leftArrow
    @node.add(@messageMod).add @message

  initEvents: =>
    @leftArrow.on 'click', =>
      #console.log 'left arrow'
      @_eventOutput.emit('back')

  showNav: =>
    #console.log 'show nav'
    #console.log @layout.wrapper.states
    Utils.animate @mainMod, @layout.wrapper.states[0]

  hideNav: =>
    #console.log 'hide nav'
    #console.log @layout.wrapper.states[1]
    Utils.animate @mainMod, @layout.wrapper.states[1]

  showLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.leftArrow.states[0]

  hideLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.leftArrow.states[1]

  showMessage: =>
    Utils.animate @messageMod, @layout.message.states[0]

  hideMessage: =>
    Utils.animate @messageMod, @layout.message.states[1]

module.exports = ReviewNavView


