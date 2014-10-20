# Famo.us
View = require 'famous/src/core/View'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Transform = require 'famous/src/core/Transform'
RenderNode = require 'famous/src/core/RenderNode'

# Pegg
Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
LayoutManager = require 'views/layouts/LayoutManager'
ProgressBarView = require 'views/ProgressBarView'
SingleCardStore = require 'stores/SingleCardStore'
NavActions = require 'actions/NavActions'

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
    PlayStore.on Constants.stores.GAME_LOADED, @loadPlayNav
    PlayStore.on Constants.stores.PAGE_CHANGE, @updateNav
    SingleCardStore.on Constants.stores.CARD_CHANGE, @loadSingleCardNav


  initSurfaces: =>
    ## Main View Modifier ##
    @mainMod = new StateModifier
      size: @layout.wrapper.size
      align: @layout.wrapper.align
      origin: @layout.wrapper.origin
      transform: @layout.wrapper.transform

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
    @progressBar = new ProgressBarView
    @progressBarMod = new StateModifier
      align: @layout.progress.align
      origin: @layout.progress.origin

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
    @node.add(@leftArrowMod).add @leftArrow
    @node.add(@rightArrowMod).add @rightArrow
    @node.add(@titleMod).add @title
    @node.add(@moodImageMod).add @moodImage
    @node.add(@progressBarMod).add @progressBar


  initEvents: =>

    @rightArrow.on 'click', =>
      @_eventOutput.emit('click', 'nextPage')

#  updateViewState: (cardIndex) =>
#    #console.log cardIndex
#    if cardIndex is 0
#      @hideLeftArrow()
#      @showRightArrow()
#    else
#      @showRightArrow()
#      @showLeftArrow()

  hideNav: =>
    Utils.animate @mainMod, @layout.hide

  showNav: =>
    Utils.animate @mainMod, @layout.show

  showSingleCardNav: =>
    Utils.animate @mainMod, @layout.show
    Utils.animate @progressBarMod, @layout.hide
    Utils.animate @moodImageMod, @layout.hide
    if @_referrer?
      Utils.animate @leftArrowMod, @layout.show

  showPlayNav: =>
    Utils.animate @mainMod, @layout.show
    Utils.animate @progressBarMod, @layout.show
    Utils.animate @moodImageMod, @layout.show
    Utils.animate @leftArrowMod, @layout.hide
    Utils.animate @rightArrowMod, @layout.hide

  loadSingleCardNav: =>
    cardTitle = SingleCardStore.getCard()
    @_referrer = SingleCardStore.getReferrer()
    if @_referrer?
      @leftArrow.on 'click', =>
        NavActions.goTo @_referrer

    console.log "Card:", cardTitle

  loadPlayNav: =>
    # change mood icon
    gameState = PlayStore.getGameState()
    @moodImage.setContent gameState.mood.url
    @progressBar.reset gameState.size

  showLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.show

  hideLeftArrow: =>
    Utils.animate @leftArrowMod, @layout.hide

  showRightArrow: =>
    Utils.animate @rightArrowMod, @layout.show

  hideRightArrow: =>
    Utils.animate @rightArrowMod, @layout.hide

  updateNav: =>
    gameState = PlayStore.getGameState()
    @title.setContent gameState.title
    @progressBar.increment(1)

module.exports = PlayNavView


