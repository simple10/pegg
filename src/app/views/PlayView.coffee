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
CommentsView = require 'views/CommentsView'
ProgressBarView = require 'views/ProgressBarView'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'

class PlayView extends View

  constructor: () ->
    super
    @initListeners()
    @initPlay()
    @initComments()

  initListeners: ->
    PlayStore.on Constants.stores.CARD_ANSWERED, @scoreCard
    PlayStore.on Constants.stores.CARD_RATED, @nextCard
    PlayStore.on Constants.stores.COMMENTS_FETCHED, @loadComments

  load: (data) ->
    surfaces = []
    @cards.sequenceFrom surfaces
    size = 0
    for own k,v of data
      card = new CardView(k, v, size: [window.innerWidth, null])
      card.pipe @cards
      surfaces.push card
      size++
    @initProgress size

  initPlay: ->
    @playMod = new StateModifier
    @playNode = @add @playMod
    @cards = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 500
    # TODO: make cards scroll on z axis
    #@cards.outputFrom (offset) ->
    #  Transform.multiply(
    #    Transform.translate offset/100, offset/100, 50
    #    Transform.rotateY(1)
    #  )
    @playNode.add @cards
    #@rate = new RateView()
    #@playNode.add @rate

  initProgress: (size) ->
    @progress = new ProgressBarView(size)
    progressMod = new StateModifier
      size: [window.innerHeight/2-20, 15]
      align: [0.5, 0.06]
      origin: [0.5, 0.5]
    @playNode.add(progressMod).add @progress

  initComments: ->
    @comments = new CommentsView
    @commentsMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, 1]
    @add(@commentsMod).add @comments
    @comments.on 'click', =>
      @toggleComments()

    @newComment = new InputView
    @newCommentMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, 1]
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @saveComment(comment)

  nextCard: =>
    @cards.goToNextPage()
    @commentsMod.setTransform Transform.translate(0, window.innerHeight, -5), {duration: 200}

  #rateCard: =>
  #  @rate.showStars()

  loadComments: =>
    @comments.load PlayStore.getComments()
    @commentsMod.setTransform Transform.translate(0, -60, -3), {duration: 200}

  toggleComments: =>
    if @commentsOpen
      @playMod.setTransform Transform.translate(0, 0, 0), {duration: 200}
      @commentsMod.setTransform Transform.translate(0, -60, -3), {duration: 200}
      @newCommentMod.setTransform Transform.translate(0, window.innerHeight-100, 0), {duration: 200}
      @commentsOpen = false
    else
      @playMod.setTransform Transform.translate(0, -300, 0), {duration: 200}
      @commentsMod.setTransform Transform.translate(0, -(window.innerHeight - 210), -3), {duration: 200}
      @newCommentMod.setTransform Transform.translate(0, -50, 0), {duration: 200}
      @commentsOpen = true

  saveComment: (comment) ->
    PlayActions.comment(comment)

  scoreCard: =>
    @progress.increment(1)


module.exports = PlayView
