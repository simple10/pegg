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

class SingleCardNavView extends View

  @DEFAULT_OPTIONS:
    cardType: null

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayNavView'

    @initSurfaces()
    @initEvents()

  setOptions: (options) =>
    @_optionsManager.patch(options)

    # update the card message
    @message.setContent SingleCardStore.getMessage()


  initSurfaces: =>

    ## Main View Modifier ##
    @mainMod = new StateModifier
      size: @layout.wrapper.size
      align: @layout.wrapper.align
      origin: @layout.wrapper.origin

    ## BACK ARROW ##
    @backArrow = new ImageSurface
      size: @layout.backArrow.size
      content: '/images/GoBack_Arrow_on@2x.png'
      classes: @layout.backArrow.classes
    @backArrowMod = new StateModifier
      align: @layout.backArrow.align
      origin: @layout.backArrow.origin

    # Attach modifiers and surfaces to the view
    @node = @add @mainMod
    @node.add(@backArrowMod).add @backArrow

  initEvents: =>
    @backArrow.on 'click', =>
      @_eventOutput.emit('back')

  showNav: =>
    Utils.animate @mainMod, @layout.wrapper.states[0]

  hideNav: =>
    Utils.animate @mainMod, @layout.wrapper.states[1]

  showBackArrow: =>
    Utils.animate @backArrowMod, @layout.backArrow.states[0]

  hideBackArrow: =>
    Utils.animate @backArrowMod, @layout.backArrow.states[1]


module.exports = SingleCardNavView


