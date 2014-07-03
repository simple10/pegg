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
ImageSurface = require 'famous/surfaces/ImageSurface'
CardView = require 'views/CardView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
CommentsView = require 'views/CommentsView'
ProgressBarView = require 'views/ProgressBarView'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'

class PlayView extends View

  constructor: () ->
    super
    @initPlay()
    @initComments()
    #@initProgress()
    @initListeners()
    @initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    PlayStore.on Constants.stores.CARD_FAIL, @cardFail
    PlayStore.on Constants.stores.CARD_WIN, @cardWin
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.CHOICES_CHANGE, (cardId) =>
      @loadChoices cardId

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

    @message = new Surface
      content: 'Generic message'
      classes: ['card__message']
      size: [window.innerWidth, 200]
    @messageMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 1]
    @playNode.add(@messageMod).add @message

    ###@back = new ImageSurface
      size: [50, 50]
      content: '/images/back.png'
      classes: ['play__back']
    @back.on 'click', =>
      @cards.goToPreviousPage()
    @backMod = new StateModifier
      align: [0, 0]
      origin: [0, 1]
    @playNode.add(@backMod).add @back###

    @forward = new ImageSurface
      size: [40, 40]
      content: '/images/forward.png'
      classes: ['play__forward']
    @forward.on 'click', =>
      @nextCard()
    @forwardMod = new StateModifier
      align: [1, 0]
      origin: [1, 1]
    @playNode.add(@forwardMod).add @forward


  initProgress: ->
    @progress = new ProgressBarView
    progressMod = new StateModifier
      #size: [window.innerHeight/2-20, 50]
      align: [0.5, 0.09]
      origin: [0.5, 0.5]
    @playNode.add(progressMod).add @progress

  initComments: ->
    @comments = new CommentsView
    @commentsMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, 1]
    @add(@commentsMod).add @comments
    @comments.on 'open', =>
      @toggleComments()

    @newComment = new InputView {placeholder: "Enter a comment..."}
    @newCommentMod = new StateModifier
      origin: [0.5, 0]
      align: [0.5, 1]
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @saveComment comment


  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    @pos = 0
    #GenericSync.register MouseSync
    @sync = new GenericSync ['mouse', 'touch'], direction: GenericSync.DIRECTION_X
    @cards.pipe @sync

    @sync.on 'update', ((data) ->
      @pos += data.delta
      console.log "pos: #{@pos}"
      return
    ).bind(@)

    @sync.on 'end', ((data) ->
      alert "data: #{data}"
      return
    ).bind(@)


  loadCards: =>
    @cardSurfaces = []
    @index = []
    @cards.sequenceFrom @cardSurfaces
    @size = 0
    @pos = 1
    for own k,v of PlayStore.getCards()
      card = new CardView k, v, size: [window.innerWidth, null]
      card.on 'comment', =>
        @toggleComments()
      card.pipe @cards
      @cardSurfaces.push card
      @index[k] = @size
      @size++
    #@progress.reset @size
    @commentsMod.setTransform Transform.translate(0, window.innerHeight, -5), { duration: 500, curve: Easing.inCubic }
    @messageMod.setTransform Transform.translate(0, 0, 0), { duration: 500, curve: Easing.inCubic }
    @forwardMod.setTransform Transform.translate(0, 0, 0), { duration: 500, curve: Easing.inCubic }

    @cards.on 'pageChange', =>
      @commentsMod.setTransform Transform.translate(0, window.innerHeight, -5), { duration: 500, curve: Easing.inCubic }
      @messageMod.setTransform Transform.translate(0, 0, 0), { duration: 500, curve: Easing.inCubic }
      @forwardMod.setTransform Transform.translate(0, 0, 0), { duration: 500, curve: Easing.inCubic }
      @pos++

  loadChoices: (cardId) =>
    @cardSurfaces[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  cardPref: =>
    @message.setClasses ['card__message__pref']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @showTopComment()
    @showNext()

  cardFail: =>
    @message.setClasses ['card__message__fail']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @fail++
    if @fail is 3
      @fail = 0
      @showTopComment()
      @showNext()
    # TODO: if 3rd fail, show comments, disable options

  cardWin: =>
    @message.setClasses ['card__message__win']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @showTopComment()
    @showNext()

  showNext: =>
    @forwardMod.setTransform Transform.translate(0, 60, 0), { duration: 500, curve: Easing.inCubic }

  showMessage: =>
    @messageMod.setTransform Transform.translate(0, 225, 0), { duration: 500, curve: Easing.inCubic }
    #@backMod.setTransform Transform.translate(0, 50, 0), { duration: 500, curve: Easing.inCubic }

  showTopComment: =>
    @commentsMod.setTransform Transform.translate(0, -50, -3), { duration: 500, curve: Easing.outCubic }

  nextCard: =>
    if @pos is @size
      PlayActions.load()
    else
      @cards.goToNextPage()


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


module.exports = PlayView
