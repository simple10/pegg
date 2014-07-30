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
StatusView = require 'views/StatusView'
CardView = require 'views/CardView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
CommentsView = require 'views/CommentsView'
PlayActions = require 'actions/PlayActions'
InputView = require 'views/InputView'
Utils = require 'lib/Utils'
StatusViewLayout = require 'views/layouts/mobile/StatusViewLayout'

class PlayView extends View

  constructor: (options) ->
    super options

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXAlign = new Transitionable(0)

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

    console.log 'initSurfaces'

    ##  CARDS ##
    @cardScrollView = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 300
    @cardScrollViewMod = new Modifier
      align: =>
        xAlign = @cardXAlign.get()
        yAlign = @_translateToAlign @cardYPos.get()
        [xAlign, yAlign]
      origin: @options.cards.origin
    @add(@cardScrollViewMod).add @cardScrollView

    ## LEFT ARROW ##
    @leftArrow = new ImageSurface
      size: @options.leftArrow.size
      content: '/images/left-arrow.png'
      classes: @options.leftArrow.classes
    @leftArrowMod = new StateModifier
      align: @options.leftArrow.align
      origin: @options.leftArrow.origin
    @add(@leftArrowMod).add @leftArrow
    @leftArrow.on 'click', =>
      @prevCard()

    ## RIGHT ARROW ##
    @rightArrow = new ImageSurface
      size: @options.rightArrow.size
      content: '/images/right-arrow.png'
      classes: @options.rightArrow.classes
    @rightArrowMod = new StateModifier
      align: @options.rightArrow.align
      origin: @options.rightArrow.origin
    @add(@rightArrowMod).add @rightArrow
    @rightArrow.on 'click', =>
      @nextCard()

    # MESSAGE ##
    @message = new Surface
      size: @options.message.size
      content: 'Generic message'
      classes: @options.message.classes
    @messageMod = new StateModifier
      align: @options.message.align
      origin: @options.message.origin
      transform: @options.message.transform
    @add(@messageMod).add @message

#    ## BUBBLE ##
#    @bubble = new ImageSurface
#      size: @options.bubble.size
#      content: '/images/talk_rounded-square.png'
#      classes: @options.bubble.classes
#    @bubbleMod = new StateModifier
#      align: @options.bubble.align
#      origin: @options.bubble.origin
#      transform: @options.bubble.transform
#    @add(@bubbleMod).add @bubble
#
#    ## UNICORN ##
#    @unicorn = new ImageSurface
#      size: @options.unicorn.size
#      content: '/images/unicorn_talk.png'
#      classes: @options.unicorn.classes
#    @unicorn.on 'click', =>
#      @cardScrollView.goToNextPage()
#    @unicornMod = new StateModifier
#      align: @options.unicorn.align
#      origin: @options.unicorn.origin
#      transform: @options.unicorn.transform
#    @add(@unicornMod).add @unicorn

    ## COMMENTS ##
    @comments = new CommentsView
    @commentsMod = new StateModifier
      align: @options.comments.align
      origin: @options.comments.origin
      transform: Transform.translate null, null, -3
    @add(@commentsMod).add @comments
    
    @comments.on 'open', =>
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
    @status = new StatusView StatusViewLayout
    @statusMod = new StateModifier
      align: @options.status.align
      origin: @options.status.origin
    @add(@statusMod).add @status


  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    onEdgeEnd = false
    minVelocity = 0.5
    minDelta = 100
    choicesShowing = false
    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'choices:showing', (card) =>
      choicesShowing = true
      @_unpipeCardsToScrollView()

    @_eventInput.on 'choices:hidden', (card) =>
      choicesShowing = false
      @_pipeCardsToScrollView()

    @_eventInput.on 'card:flipped', (card) =>
      choicesShowing = false
      @_pipeCardsToScrollView()

    @_eventInput.pipe @sync
    @cardScrollView.on 'onEdge', () =>
      # check to see if we have hit the end, i.e. bottom or right most item
      if @cardScrollView._onEdge is 1 then onEdgeEnd = true
    @cardScrollView.on 'offEdge', () =>
      onEdgeEnd = false
    @cardScrollView.on 'pageChange', (data) =>
      # get the state of the current card
      # used to determine if comments need to be hidden or shown
      card = @cardViews[@cardScrollView._node.index]
      if data.direction is 1
        @nextCard()
      if data.direction is -1
        @prevCard()
      # showChoices is true when the front of the card is visible
      if card.showChoices
        @hideComments()
      else
        @showComments()

    isMovingY = false
    isMovingX = false
    startPos = 0

    @sync.on 'start', (data) =>
      startPos = @cardYPos.get()

    @sync.on 'update', ((data) ->
      dx = data.delta[0]
      dy = data.delta[1]
      if !isMovingX && !isMovingY
        if Math.abs(dy) > Math.abs(dx)
          @_unpipeCardsToScrollView()
          isMovingY = true
        else if !choicesShowing
          @_pipeCardsToScrollView()
          isMovingX = true
      if @_commentsIsExpanded
        @_unpipeCardsToScrollView()
      if isMovingY
        if PlayStore.getCurrentCardIsAnswered()
          currentPosition = @cardYPos.get()
          # calculate the max Y offset to prevent the user from being able
          # to drag the card past this point
          max = @options.cards.states[1].align[1] * Utils.getViewportHeight()
          pos = Math.min Math.abs(max), Math.abs(currentPosition + dy)
          @cardYPos.set(-pos)
    ).bind(@)

    @sync.on 'end', ((data) ->
      # figure out if we need to show/hide the comments if moving along the Y axis
      if isMovingY
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
        else if delta
          if !@_commentsIsExpanded
            @collapseComments()
          else 
            @expandComments()
      else if isMovingX
        if onEdgeEnd then @nextCard()
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
    @showRightArrow()
    @showMessage()
    @hideLeftArrow()
    @message.setContent PlayStore.getMessage(@cardViews[0].getType())

  _pipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].pipe @cardScrollView
    null

  _unpipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].unpipe @cardScrollView
    null

  _translateToAlign: (delta, axis) =>
    axis = axis || 'Y'
    if axis is 'Y'
      delta / Utils.getViewportHeight()
    else
      delta / Utils.getViewportWidth()

  loadChoices: (cardId) =>
    @cardViews[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  loadStatus: =>
    @hideComments()
    @hideRightArrow()
    @hideLeftArrow()
    @hideMessage()
    @status.load PlayStore.getStatus()
    @showStatus()

  nextCard: () =>
    @showLeftArrow()
    PlayActions.nextCard()

  prevCard: () =>
    PlayActions.prevCard()

  saveComment: (comment) ->
    PlayActions.comment(comment)

  cardPref: =>
    #@message.setClasses ['card__message__pref']
    #@message.setContent PlayStore.getMessage('pref')
    Utils.animate @commentsMod, @options.comments.states[1]

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent PlayStore.getMessage('fail')

  cardWin: =>
    #@message.setClasses ['card__message__win']
    #@message.setContent PlayStore.getMessage('win')
    @showComments()

  showRightArrow: =>
    Utils.animate @rightArrowMod, @options.rightArrow.states[0]

  hideRightArrow: =>
    Utils.animate @rightArrowMod, @options.rightArrow.states[1]

  showLeftArrow: =>
    Utils.animate @leftArrowMod, @options.leftArrow.states[0]

  hideLeftArrow: =>
    Utils.animate @leftArrowMod, @options.leftArrow.states[1]

  showMessage: =>
    Utils.animate @messageMod, @options.message.states[0]

  hideMessage: =>
    Utils.animate @messageMod, @options.message.states[1]

  showComments: =>
    Utils.animate @commentsMod, @options.comments.states[1]

  hideComments: =>
    Utils.animate @commentsMod, @options.comments.states[0]
    @newComment.setAlign @options.newComment.states[0].align

  collapseComments: =>
    # slide the cards down to their starting position
    @cardYPos.set(0, @options.cards.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @commentsMod, @options.comments.states[1]
    @._commentsIsExpanded = false;
    @newComment.setAlign @options.newComment.states[0].align

  expandComments: =>
    maxCardYPos = @options.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @options.cards.states[1].transition)
    # slide the comments up
    Utils.animate @commentsMod, @options.comments.states[2]
    @._commentsIsExpanded = true;
    @newComment.setAlign @options.newComment.states[1].align

  showCards: =>
    @cardScrollViewMod.opacityFrom 0.999
    cardsTransition = @options.cards.states[0].transition
    cardX = @options.cards.states[0].align[0]
    cardY = @options.cards.states[0].align[1] * Utils.getViewportHeight()
    # slide the cards left onto the screen
    @cardXAlign.set(cardX, cardsTransition)
    @cardYPos.set(cardY, cardsTransition)
    # slide the status left off the screen
    Utils.animate @statusMod, @options.status.states[2], @moveStatusToStart

  showStatus: =>
    @statusMod.setOpacity 0.999
    cardsTransition = @options.cards.states[2].transition
    cardX = @options.cards.states[2].align[0]
    # slide cards left off the screen
    @cardXAlign.set cardX, cardsTransition
    # slide status left onto the screen
    Utils.animate @statusMod, @options.status.states[1], @moveCardsToStart

  moveCardsToStart: =>
    @cardScrollViewMod.opacityFrom 0.001
    cardX = @options.cards.states[3].align[0]
    cardY = @options.cards.states[3].align[1] * Utils.getViewportHeight()
    @cardXAlign.set cardX
    @cardYPos.set cardY

  moveStatusToStart: =>
    @statusMod.setOpacity 0.001
    Utils.animate @statusMod, @options.status.states[0]

module.exports = PlayView
