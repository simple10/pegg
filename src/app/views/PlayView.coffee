
View = require 'famous/core/View'
Transform = require 'famous/core/Transform'
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
PlayCardsView = require 'views/PlayCardsView'
Utils = require 'lib/Utils'
PlayStatusView = require 'views/PlayStatusView'
Lightbox = require 'famous/views/Lightbox'
Easing = require 'famous/transitions/Easing'
LayoutManager = require 'views/layouts/LayoutManager'

class PlayView extends View

  constructor: (options) ->
    super options
    @initViews()
    @initListeners()

  initListeners: ->
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.STATUS_CHANGE, @loadStatus

  initViews: ->
    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    ## CARDS VIEW ##
    @cardsView = new PlayCardsView @layout

    ## STATUS VIEW ##
    @statusView = new PlayStatusView

    viewportWidth = Utils.getViewportWidth()
    @lightbox = new Lightbox
      inOpacity: 1
      outOpacity: 0
      inOrigin: [0, 0]
      outOrigin: [1, 0]
      showOrigin: [0.5, 0.5]
      inTransform: Transform.translate viewportWidth, 0, -300
      outTransform: Transform.translate -viewportWidth, 0, -1000
      inTransition: { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
    @add @lightbox


  loadStatus: =>
    @statusView.load PlayStore.getStatus()
    @lightbox.show @statusView

  loadCards: =>
    @lightbox.show @cardsView


module.exports = PlayView
