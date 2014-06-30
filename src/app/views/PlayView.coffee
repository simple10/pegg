require './scss/play.scss'

View = require 'famous/core/View'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
Timer = require 'famous/utilities/Timer'
Easing = require 'famous/transitions/Easing'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'

CardView = require 'views/CardView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
CommentsView = require 'views/CommentsView'
ProgressBarView = require 'views/ProgressBarView'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'

class PlayView extends View

  constructor: () ->
    super
    @initPlay()
    @initComments()
    @initProgress()
    @initListeners()

  initListeners: ->
    PlayStore.on Constants.stores.PLAY_SAVED, @adjustProgress
    PlayStore.on Constants.stores.CARD_RATED, @nextCard
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.CHOICES_CHANGE, (cardId) =>
      @loadChoices cardId

  loadCards: =>
    @cardSurfaces = []
    @index = []
    @cards.sequenceFrom @cardSurfaces
    @size = 0
    @pos = 1
    for own k,v of PlayStore.getCards()
      card = new CardView(k, v, size: [window.innerWidth, null])
      card.pipe @cards
      @cardSurfaces.push card
      @index[k] = @size
      @size++
    @progress.reset(@size)

  loadChoices: (cardId) ->
    @cardSurfaces[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  initPlay: ->
    @playMod = new StateModifier
    @playNode = @add @playMod
    @cards = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 400
    # TODO: make cards scroll on z axis
    #@cards.outputFrom (offset) ->
    #  Transform.multiply(
    #    Transform.translate offset/100, offset/100, 50
    #    Transform.rotateY(1)
    #  )
    @playNode.add @cards

  initProgress: ->
    @progress = new ProgressBarView
    progressMod = new StateModifier
      size: [window.innerHeight/2-20, 15]
      align: [0.5, 0.08]
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

    @newComment = new InputView {placeholder: "Enter a comment..."}
    @newCommentMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, 1]
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @saveComment(comment)

  nextCard: =>
    if @pos is @size
      PlayActions.load()
    else
      @pos++
      @cards.goToNextPage()
    @commentsMod.setTransform Transform.translate(0, window.innerHeight, -5), { duration: 500, curve: Easing.inCubic }

  toggleComments: =>
    transition = { duration: 500, curve: Easing.outCubic }
    if @commentsOpen
      @playMod.setTransform Transform.translate(0, 0, 0), transition
      @commentsMod.setTransform Transform.translate(0, -60, -3), transition
      @newCommentMod.setTransform Transform.translate(0, window.innerHeight-200, 0), transition
      @commentsOpen = false
    else
      @playMod.setTransform Transform.translate(0, -300, 0), transition
      @commentsMod.setTransform Transform.translate(0, -(window.innerHeight - 210), -3), transition
      @newCommentMod.setTransform Transform.translate(0, -70, 0), transition
      @commentsOpen = true

  saveComment: (comment) ->
    PlayActions.comment(comment)

  adjustProgress: =>
    @progress.increment(1)
    @commentsMod.setTransform Transform.translate(0, -50, -3), { duration: 500, curve: Easing.outCubic }


module.exports = PlayView
