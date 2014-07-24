require './scss/play.scss'

View = require 'famous/core/View'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Scrollview = require 'famous/views/Scrollview'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
Transitionable = require 'famous/transitions/Transitionable'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'
Timer = require 'famous/utilities/Timer'

CardView = require 'views/CardView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
CommentsView = require 'views/CommentsView'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'
Utils = require 'lib/Utils'
StatusView = require 'views/StatusView'

class PlayView extends View

  constructor: (options) ->
    super options

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0);
    # @cardXPos = new Transitionable(0);

    @initSurfaces()
    @initListeners()
    @initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    PlayStore.on Constants.stores.CARD_FAIL, @cardFail
    PlayStore.on Constants.stores.CARD_WIN, @cardWin
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.STATUS_CHANGE, @loadStatus
    PlayStore.on Constants.stores.CHOICES_CHANGE, (cardId) =>
      @loadChoices cardId

  initSurfaces: ->

    ##  CARDS ##
    @cardScrollView = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 400
    @cardScrollViewMod = new Modifier
      align: =>
        [0, @_translateToAlign @cardYPos.get()]
      origin: @options.cards.origin
    @add(@cardScrollViewMod).add @cardScrollView

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
      content: '/images/talk_rounded-square.png'
      classes: @options.bubble.classes
    @bubbleMod = new StateModifier
      align: @options.bubble.align
      origin: @options.bubble.origin
      transform: @options.bubble.transform
    @add(@bubbleMod).add @bubble

    ## UNICORN ##
    @unicorn = new ImageSurface
      size: @options.unicorn.size
      content: '/images/unicorn_talk.png'
      classes: @options.unicorn.classes
    @unicorn.on 'click', =>
      @cardScrollView.goToNextPage()
      # @nextCard() # TEMP... remove this when 'pageChange' works
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
      transform: Transform.translate null, null, -3
    @add(@commentsMod).add @comments
    
    @comments.on 'open', =>
      console.log 'open comments'
      @expandComments()

    @newComment = new InputView
      size: @options.newComment.size
      placeholder: "Enter a comment..."
      align: @options.newComment.states[1].align
      origin: @options.newComment.origin
    @newCommentMod = new StateModifier
      align: @options.newComment.align
      origin: @options.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.setValue ''
      @saveComment comment

    ## STATUS ##
    @status = new StatusView
      size: @options.status.size
    @statusMod = new StateModifier
      align: @options.status.align
      origin: @options.status.origin
    @add(@statusMod).add @status


  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    minVelocity = 0.5
    minDelta = 100
    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'choices:showing', (card) =>
      @_unpipeCardsToScrollView()

    @_eventInput.on 'choices:hidden', (card) =>
      @_pipeCardsToScrollView()

    @_eventInput.on 'card:flipped', (card) =>
      @_pipeCardsToScrollView()
    
    @_eventInput.pipe @sync
    
    # @TODO 'pageChange' is not consistent right now, but Famo.us is working on it
    @cardScrollView.on 'pageChange', (data) =>
      # get the state of the current card to determine if comments
      # need to be hidden or shown
      card = @cardViews[@cardScrollView._node.index]

      if data.direction is 1 then @nextCard()
      if data.direction is -1 then @prevCard()
        
      # showChoices is true when the front of the card is visible
      if card.showChoices
        @hideMessage()
        @hideComments()
      else
        @showComments()

    isMovingY = false
    isMovingX = false
    startPos = 0

    @sync.on 'start', ((data) =>
      startPos = @cardYPos.get();
    )

    @sync.on 'update', ((data) ->
      dx = data.delta[0]
      dy = data.delta[1]

      if !isMovingX && !isMovingY
        if Math.abs(dy) > Math.abs(dx)
          @_unpipeCardsToScrollView()
          isMovingY = true
        else
          @_pipeCardsToScrollView()
          isMovingX = true

      if @_commentsIsExpanded
        @_unpipeCardsToScrollView()

      if isMovingY
        if PlayStore.getCurrentCardIsAnswered()
          currentPosition = @cardYPos.get();
          # calculate the max Y offset to prevent the user from being able
          # to drap the card past this point
          max = @options.cards.states[1].align[1] * Utils.getViewportHeight()
          pos = Math.min Math.abs(max), Math.abs(currentPosition + dy)
          @cardYPos.set(-pos)

    ).bind(@)

    @sync.on 'end', ((data) ->
      # retrieve the Y velocity
      velocity = data.velocity[1]

      # calculate the total position change
      delta = startPos - @cardYPos.get()

      # swiping/dragging up and crossed pos and vel threshold
      if delta > minDelta && Math.abs(velocity) > minVelocity
        @expandComments()
      # swiping/dragging down and crossed pos and vel threshold
      else if delta < -minDelta && Math.abs(velocity) > minVelocity
        @collapseComments()
      # otherwise threshold not met, so return to original position
      else
        if !@_commentsIsExpanded then @collapseComments()
        else @expandComments()
        

      # reset axis movement flags
      isMovingY = false;
      isMovingX = false;

    ).bind(@)

  loadCards: =>
    @cardViews = []
    @index = []
    @cardScrollView.sequenceFrom @cardViews
    i = 0
    for own cardId, cardObj of PlayStore.getCards()
      card = new CardView cardId, cardObj, size: [window.innerWidth, null]
      card.on 'comment', =>
        @collapseComments()
      card.pipe @
      @cardViews.push card
      @index[cardId] = i++

    @_pipeCardsToScrollView()
    @showCards()

  _pipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].pipe @cardScrollView
    null

  _unpipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].unpipe @cardScrollView
    null

  _translateToAlign: (delta) =>
    delta / Utils.getViewportHeight()

  loadChoices: (cardId) =>
    @cardViews[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  loadStatus: =>
    @hideComments()
    @hideMessage()
    @status.load PlayStore.getStatus()
    @showStatus()

  nextCard: () =>
    PlayActions.nextCard()

  prevCard: () =>
    PlayActions.prevCard()

  saveComment: (comment) ->
    PlayActions.comment(comment)

  cardPref: =>
    @message.setClasses ['card__message__pref']
    @message.setContent PlayStore.getMessage('pref')
    @showMessage()
    Utils.animate @commentsMod, @options.comments.states[1]

  cardFail: =>
    @message.setClasses ['card__message__fail']
    @message.setContent PlayStore.getMessage('fail')

  cardWin: =>
    @message.setClasses ['card__message__win']
    @message.setContent PlayStore.getMessage('win')
    @showMessage()
    @showComments()

  slideUp: =>
    console.log 'slideUp'
    maxCardYPos = @options.cards.states[1].align[1] * Utils.getViewportHeight()
    @cardYPos.set(maxCardYPos, @options.cards.states[1].transition)
    Utils.animate @commentsMod, @options.comments.states[2]

  slideDown: =>
    console.log 'slideDown'
    @cardYPos.set(0, @options.cards.states[0].transition)
    Utils.animate @commentsMod, @options.comments.states[1]

  showMessage: =>
    Utils.animate @messageMod, @options.message.states[1]
    Utils.animate @bubbleMod, @options.bubble.states[1]
    Utils.animate @unicornMod, @options.unicorn.states[1]

  hideMessage: =>
    Utils.animate @messageMod, @options.message.states[0]
    Utils.animate @messageMod, @options.message.states[2]
    Utils.animate @bubbleMod, @options.bubble.states[0]
    Utils.animate @bubbleMod, @options.bubble.states[2]
    Utils.animate @unicornMod, @options.unicorn.states[0]
    Utils.animate @unicornMod, @options.unicorn.states[2]

  showComments: =>
    Utils.animate @commentsMod, @options.comments.states[1]

  hideComments: =>
    Utils.animate @commentsMod, @options.comments.states[0]
    @newComment.setAlign @options.newComment.states[0].align

  collapseComments: =>
    # Utils.animate @cardScrollViewMod, @options.cards.states[0]
    # Utils.animate @commentsMod, @options.comments.states[1]
    @slideDown()
    @._commentsIsExpanded = false;
    @newComment.setAlign @options.newComment.states[0].align

  expandComments: =>
    # Utils.animate @cardScrollViewMod, @options.cards.states[1]
    # Utils.animate @commentsMod, @options.comments.states[2]
    @slideUp()
    @._commentsIsExpanded = true;
    @newComment.setAlign @options.newComment.states[1].align

  showCards: =>
    Utils.animate @cardScrollViewMod, @options.cards.states[0]
    Utils.animate @statusMod, @options.status.states[0]

  showStatus: =>
    @hideMessage()
    @newComment.setAlign @options.newComment.states[0].align
    Utils.animate @commentsMod, @options.comments.states[0]
    Utils.animate @cardScrollViewMod, @options.cards.states[2]
    Utils.animate @statusMod, @options.status.states[1]

module.exports = PlayView
