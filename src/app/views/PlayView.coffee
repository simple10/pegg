require './scss/play.scss'

View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
CardView = require 'views/CardView'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
RateView = require 'views/RateView'
StatusView = require 'views/StatusView'
ProgressBarView = require 'views/ProgressBarView'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'

class PlayView extends View

  constructor: () ->
    super
    @initListeners()
    @initPlay()
    @initStatus()

  initListeners: ->
    PlayStore.on Constants.stores.CARD_ANSWERED, @rateCard
    PlayStore.on Constants.stores.CARD_RATED, @nextCard
    PlayStore.on Constants.stores.UNLOCK_ACHIEVED, @showStatus
    PlayStore.on Constants.stores.PLAY_CONTINUED, @hideStatus

  load: (data) ->
    surfaces = []
    @cards.sequenceFrom surfaces
    i = 0
    while i < data.length
      card = new CardView(data[i], size: [350, null])
      card.pipe @cards
      surfaces.push card
      i++
    @initProgress data.length

  initPlay: ->
    @playMod = new StateModifier
    @playNode = @add @playMod
    @cards = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 1000
    # TODO: make cards scroll on z axis
    #@cards.outputFrom (offset) ->
    #  Transform.multiply(
    #    Transform.translate offset/100, offset/100, 50
    #    Transform.rotateY(1)
    #  )
    @playNode.add @cards
    @rate = new RateView()
    @playNode.add @rate

   initProgress: (size) ->
    @progress = new ProgressBarView(size)
    progressMod = new StateModifier
      size: [window.innerHeight/2-20, 15]
      align: [0.5, 0.06]
      origin: [0.5, 0.5]
    @playNode.add(progressMod).add @progress

  initStatus: ->
    status = new StatusView()
    @statusMod = new StateModifier
      size: [window.innerWidth, window.innerHeight]
      align: [0.5, 0]
      origin: [0.5, 1]
    @add(@statusMod).add status

  nextCard: =>
    @progress.increment(1)
    @cards.goToNextPage()

  showStatus: =>
    @playMod.setTransform(
      Transform.translate 0, window.innerHeight, 0
      duration: 800
      curve: Easing.inBack
    )
    @statusMod.setTransform(
      Transform.translate 0, window.innerHeight, 0
      duration: 800
      curve: Easing.inBack
    )

  hideStatus: =>
    @playMod.setTransform(
      Transform.translate 0, 0, 0
      duration: 800
      curve: Easing.inBack
    )
    @statusMod.setTransform(
      Transform.translate 0, -window.innerHeight, 0
      duration: 800
      curve: Easing.inBack
    )


  rateCard: =>
    @rate.showStars()


module.exports = PlayView
