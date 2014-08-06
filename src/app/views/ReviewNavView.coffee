View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Transform = require 'famous/core/Transform'
RenderNode = require 'famous/core/RenderNode'

Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
LayoutManager = require 'views/layouts/LayoutManager'

class PlayNavView extends View

  @DEFAULT_OPTIONS:
    cardType: 'pegg'
  
  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayNavView'

    @initSurfaces()
    @initEvents()

    PlayStore.on Constants.stores.CARDS_CHANGE, @initViewState
    PlayStore.on Constants.stores.CARD_CHANGE, @updateViewState

  setOptions: (options) => 
    @_optionsManager.patch(options);

    # update the card message
    @message.setContent PlayStore.getMessage(@options.cardType)


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
    

    ## RIGHT ARROW ##
    @rightArrow = new ImageSurface
      size: @layout.rightArrow.size
      content: '/images/right-arrow.png'
      classes: @layout.rightArrow.classes
    @rightArrowMod = new StateModifier
      align: @layout.rightArrow.align
      origin: @layout.rightArrow.origin

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
    @node.add(@rightArrowMod).add @rightArrow
    @node.add(@messageMod).add @message

  initEvents: =>
    @leftArrow.on 'click', =>
      #console.log 'left arrow'
      @_eventOutput.emit('click', 'prevCard')

    @rightArrow.on 'click', =>
      #console.log 'right arrow'
      @_eventOutput.emit('click', 'nextCard')

  initViewState: =>
    @showNav()
    @showRightArrow()
    @showMessage()
    @hideLeftArrow()

  updateViewState: (cardIndex) =>
    #console.log cardIndex
    if cardIndex is 0
      @hideLeftArrow()
      @showRightArrow()
    else if cardIndex is 2
      @showLeftArrow()
    else
      @showRightArrow()
      @showLeftArrow()

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

  showRightArrow: =>
    Utils.animate @rightArrowMod, @layout.rightArrow.states[0]

  hideRightArrow: =>
    Utils.animate @rightArrowMod, @layout.rightArrow.states[1]

  showMessage: =>
    Utils.animate @messageMod, @layout.message.states[0]

  hideMessage: =>
    Utils.animate @messageMod, @layout.message.states[1]

module.exports = PlayNavView


