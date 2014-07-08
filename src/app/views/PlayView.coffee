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

  @DEFAULT_OPTIONS:
    cards:
      align: [0, 0.04]
      origin: [0, 0]
      states: [
        {
          delay: 0
          align: [0, 0.04]
          transition: {duration: 500, curve: Easing.outQuad}
        }
        {
          delay: 0
          align: [0, -0.6]
          transition: {duration: 500, curve: Easing.outQuad}
        }
      ]
    unicorn:
      size: [80, 160]
      classes: ['play__unicorn']
      align: [0.17, 0.4]
      origin: [0.5, 0.5]
      transform: Transform.translate null, null, -10000
      states: [
        {
          delay: 0
          align: [0.17, 0.4]
          transform: Transform.translate null, null, -10000
          transition: {duration: 1000, curve: Easing.inQuad}
        }
        {
          delay: 0
          align: [0.17, 0.18]
          transform: Transform.translate null, null, -3
          transition: {duration: 500, curve: Easing.outQuad}
        }
      ]
    bubble:
      size: [250, 100]
      classes: ['card__message__bubble']
      align: [0.6, 0.4]
      origin: [0.5, 0.5]
      transform: Transform.translate null, null, -10000
      states: [
        {
          delay: 20
          align: [0.6, 0.4]
          transform: Transform.translate null, null, -10000
          transition: {duration: 1000, curve: Easing.inQuad}
        }
        {
          delay: 20
          align: [0.6, 0.12]
          transform: Transform.translate null, null, -4
          transition: {duration: 500, curve: Easing.outQuad}
        }
      ]
    message:
      size: [300, 200]
      classes: ['card__message']
      align: [0.5, 0.4]
      origin: [0.5, 0.5]
      transform: Transform.translate null, null, -10000
      states: [
        {
          delay: 20
          align: [0.5, 0.4]
          transform: Transform.translate null, null, -10000
          transition: {duration: 1000, curve: Easing.inQuad}
        }
        {
          delay: 20
          align: [0.6, 0.26]
          transform: Transform.translate null, null, -3
          transition: {duration: 500, curve: Easing.inBounce}
        }
      ]
    comments:
      origin: [0.5, 0]
      align: [0.5, 1]
      states: [
        {
          delay: 0
          align: [0.5, 1]
          transition: {duration: 500, curve: Easing.inQuad}
        }
        {
          delay: 0
          align: [0.5, 0.9]
          transition: {duration: 500, curve: Easing.outQuad}
        }
        {
          delay: 0
          align: [0.5, 0.3]
          transition: {duration: 500, curve: Easing.outQuad}
        }
      ]
    newComment:
      origin: [0.5, 0]
      align: [0.5, 1]
      states: [
        {
          delay: 0
          align: [0.5, 1]
          transition: {duration: 500, curve: Easing.inQuad}
        }
        {
          delay: 0
          align: [0.5, 0.9]
          transition: {duration: 500, curve: Easing.outQuad}
        }
      ]
  constructor: (options) ->
    super options
    @initSurfaces()
    @initListeners()
    #@initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    PlayStore.on Constants.stores.CARD_FAIL, @cardFail
    PlayStore.on Constants.stores.CARD_WIN, @cardWin
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.CHOICES_CHANGE, (cardId) =>
      @loadChoices cardId

  initSurfaces: ->
    ##  CARDS ##
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
    @cardsMod = new StateModifier
      align: @options.cards.align
      origin: @options.cards.origin
    @add(@cardsMod).add @cards

    ## MESSAGE ##
    @message = new Surface
      size: @options.message.size
      content: 'Generic message'
      classes: @options.message.classes
    @messageMod = new StateModifier
      align: @options.message.align
      origin: @options.message.origin
      transform: @options.message.transform
    @add(@messageMod).add @message

    ## BUBBLE ##
    @bubble = new ImageSurface
      size: @options.bubble.size
      content: '/images/talk_medium.png'
      classes: @options.bubble.classes
    @bubbleMod = new StateModifier
      align: @options.bubble.align
      origin: @options.bubble.origin
      transform: @options.bubble.transform
    @add(@bubbleMod).add @bubble

    ## UNICORN ##
    @unicorn = new ImageSurface
      size: @options.unicorn.size
      content: '/images/mascot_medium.png'
      classes: @options.unicorn.classes
    @unicorn.on 'click', =>
      @nextCard()
    @unicornMod = new StateModifier
      align: @options.unicorn.align
      origin: @options.unicorn.origin
      transform: @options.unicorn.transform
    @add(@unicornMod).add @unicorn

    ## COMMENTS ##
    @comments = new CommentsView
    @commentsMod = new StateModifier
      align: @options.comments.align
      origin: @options.comments.origin
    @add(@commentsMod).add @comments
    @comments.on 'open', =>
      @toggleComments()
    @newComment = new InputView {placeholder: "Enter a comment..."}
    @newCommentMod = new StateModifier
      align: @options.newComment.align
      origin: @options.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @saveComment comment

#  ## PROGRESS ##
#    @progress = new ProgressBarView
#    progressMod = new StateModifier
#      #size: [window.innerHeight/2-20, 50]
#      align: [0.5, 0.09]
#      origin: [0.5, 0.5]
#    @playNode.add(progressMod).add @progress


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

    @cards.on 'pageChange', =>
      @hideMessage()
      @pos++

  loadChoices: (cardId) =>
    @cardSurfaces[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  saveComment: (comment) ->
    PlayActions.comment(comment)

  cardPref: =>
    @message.setClasses ['card__message__pref']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @animate @commentsMod, @options.comments.states[1]

  cardFail: =>
    @message.setClasses ['card__message__fail']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @fail++
    if @fail is 3
      @fail = 0
      @animate @commentsMod, @options.comments.states[1]
    # TODO: if 3rd fail, show comments, disable options

  cardWin: =>
    @message.setClasses ['card__message__win']
    @message.setContent PlayStore.getMessage()
    @showMessage()
    @animate @commentsMod, @options.comments.states[1]

  showMessage: =>
    @animate @messageMod, @options.message.states[1]
    @animate @bubbleMod, @options.bubble.states[1]
    @animate @unicornMod, @options.unicorn.states[1]

  hideMessage: =>
    @animate @messageMod, @options.message.states[0]
    @animate @bubbleMod, @options.bubble.states[0]
    @animate @unicornMod, @options.unicorn.states[0]

  nextCard: =>
    if @pos is @size
      PlayActions.load()
    else
      @cards.goToNextPage()

  toggleComments: =>
    if @commentsOpen
      @animate @cardsMod, @options.cards.states[0]
      @animate @commentsMod, @options.comments.states[1]
      @animate @newCommentMod, @options.newComment.states[0]
      @commentsOpen = false
    else
      @animate @cardsMod, @options.cards.states[1]
      @animate @commentsMod, @options.comments.states[2]
      @animate @newCommentMod, @options.newComment.states[1]
      @commentsOpen = true


  animate: (mod, state) ->
    Timer.after (->
      if state.origin?
        mod.setOrigin state.origin, state.transition
      if state.align?
        mod.setAlign state.align, state.transition
      if state.scale?
        mod.setTransform Transform.scale(state.scale...), state.transition
      if state.transform?
        mod.setTransform state.transform, state.transition
    ), state.delay


module.exports = PlayView
