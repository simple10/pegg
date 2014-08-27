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

Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
PlayActions = require 'actions/PlayActions'

CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
InputView = require 'views/InputView'
PlayNavView = require 'views/PlayNavView'


class PlayCardsView extends View

  constructor: (options) ->
    super options
    
    @_viewportHeight = Utils.getViewportHeight();
    @_viewportWidth = Utils.getViewportWidth();

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXAlign = new Transitionable(0)

    @initViews()
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

  initViews: ->

    ## CARDS ##
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

    ## NAV ##
    @navView = new PlayNavView
    @navView._eventOutput.on 'click', (data) =>
      if data is 'prevCard'
        @prevCard(true)
      else if data is 'nextCard'
        @nextCard(true)  
    @add(@navView)
    @navView.hideRightArrow()

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
      isMovingY = false
      isMovingX = false
    ).bind(@)

  loadCards: =>
    @cardViews = []
    @index = []
    @cardScrollView.sequenceFrom @cardViews
    i = 0
    for own cardId, cardObj of PlayStore.getCards()
      name = cardObj.firstName
      card = new CardView
      card.loadCard cardId, cardObj
      card.on 'comment', =>
        @collapseComments()
      card.pipe @
      @cardViews.push card
      @index[cardId] = i++

    @_pipeCardsToScrollView()
    @navView.setOptions {
      'cardType': PlayStore.getCurrentCardsType()
      'firstName': name
    }

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
      delta / @_viewportHeight
    else
      delta / @_viewportWidth

  loadChoices: (cardId) =>
    @cardViews[@index[cardId]].loadChoices cardId

  loadComments: =>
    @comments.load PlayStore.getComments()

  nextCard: (triggerPageChange) =>
    if triggerPageChange
      if @cardScrollView.getCurrentIndex() is PlayStore.getSetLength() - 1
        # tapped next button and at end of card set
        PlayActions.nextCard()
      else
        # tapped next button and not at end of card set
        @cardScrollView.goToNextPage()
    else
      # swiped left
      PlayActions.nextCard()
    @navView.hideRightArrow()

  prevCard: (triggerPageChange) =>
    if triggerPageChange
      @cardScrollView.goToPreviousPage()
      console.log @cardScrollView.getCurrentIndex()
    else PlayActions.prevCard()

  saveComment: (comment) ->
    PlayActions.comment(comment)

  cardPref: =>
    Utils.animate @commentsMod, @options.comments.states[1]
    @navView.showRightArrow()

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent PlayStore.getMessage('fail')

  cardWin: =>
    @showComments()
    @navView.showRightArrow()

  showComments: =>
    Utils.animate @commentsMod, @options.comments.states[1]

  hideComments: =>
    Utils.animate @commentsMod, @options.comments.states[0]
    @newComment.setAlign @options.newComment.states[0].align

  collapseComments: =>
    @navView.showNav()
    # slide the cards down to their starting position
    @cardYPos.set(0, @options.cards.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @commentsMod, @options.comments.states[1]
    @._commentsIsExpanded = false;
    @newComment.setAlign @options.newComment.states[0].align

  expandComments: =>
    @navView.hideNav()
    maxCardYPos = @options.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @options.cards.states[1].transition)
    # slide the comments up
    Utils.animate @commentsMod, @options.comments.states[2]
    @._commentsIsExpanded = true;
    @newComment.setAlign @options.newComment.states[1].align


module.exports = PlayCardsView
