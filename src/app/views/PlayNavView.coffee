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
ProgressBarView = require 'views/ProgressBarView'

class PlayNavView extends View

  @DEFAULT_OPTIONS:
    cardType: 'pegg'
  
  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayNavView'

    @initSurfaces()
    @initEvents()
    @initListeners()

  initListeners: ->
    PlayStore.on Constants.stores.GAME_LOADED, @loadNav
    PlayStore.on Constants.stores.GAME_CHANGE, @updateNav


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

    ## MOOD IMAGE ##
    @moodImage = new ImageSurface
      size: @layout.moodImage.size
      classes: @layout.moodImage.classes
    @moodImageMod = new StateModifier
      align: @layout.moodImage.align
      origin: @layout.moodImage.origin

    ## PROGRESS BAR ##
    @progressBar = new ProgressBarView @layout.progressBarView
    @progressBarMod = new StateModifier
      align: @layout.progressBarView.align
      origin: @layout.progressBarView.origin

    ## RIGHT ARROW ##
    @rightArrow = new ImageSurface
      size: @layout.rightArrow.size
      content: '/images/right-arrow.png'
      classes: @layout.rightArrow.classes
    @rightArrowMod = new StateModifier
      align: @layout.rightArrow.align
      origin: @layout.rightArrow.origin

    ## TITLE ##
    @title = new Surface
      size: @layout.title.size
      content: ''
      classes: @layout.title.classes
    @titleMod = new StateModifier
      align: @layout.title.align
      origin: @layout.title.origin
      transform: @layout.title.transform

    # Attach modifiers and surfaces to the view
    @node = @add @mainMod
#    @node.add(@leftArrowMod).add @leftArrow
    @node.add(@rightArrowMod).add @rightArrow
    @node.add(@titleMod).add @title
    @node.add(@moodImageMod).add @moodImage
    @node.add(@progressBarMod).add @progressBar


  initEvents: =>
    @leftArrow.on 'click', =>
      #console.log 'left arrow'
      @_eventOutput.emit('click', 'prevPage')

    @rightArrow.on 'click', =>
      #console.log 'right arrow'
      @_eventOutput.emit('click', 'nextPage')

  initViewState: =>
    @progressBar.reset PlayStore.getSetLength()

#    @hideRightArrow()
#    @hideLeftArrow()

#  updateViewState: (cardIndex) =>
#    #console.log cardIndex
#    if cardIndex is 0
#      @hideLeftArrow()
#      @showRightArrow()
#    else
#      @showRightArrow()
#      @showLeftArrow()

  showNav: =>
    Utils.animate @mainMod, @layout.wrapper.states[0]

  hideNav: =>
    Utils.animate @mainMod, @layout.wrapper.states[1]

  loadNav: =>
    # change mood icon
    gameState = PlayStore.getGameState()
    @moodImage.setContent gameState.mood.url
    @title.setContent gameState.title
    @progressBar.reset gameState.size

  showLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.leftArrow.states[0]

  hideLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.leftArrow.states[1]

  showRightArrow: =>
    Utils.animate @rightArrowMod, @layout.rightArrow.states[0]

  hideRightArrow: =>
    Utils.animate @rightArrowMod, @layout.rightArrow.states[1]

  incrementProgressBar: =>
    @progressBar.increment(1)

module.exports = PlayNavView


