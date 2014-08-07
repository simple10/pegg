require './scss/play.scss'

View = require 'famous/core/View'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
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
ReviewActions = require 'actions/ReviewActions'
ReviewStore = require 'stores/ReviewStore'
CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
InputView = require 'views/InputView'
ReviewNavView = require 'views/ReviewNavView'

LayoutManager = require 'views/layouts/LayoutManager'
StatusViewLayout = require 'views/layouts/mobile/StatusViewLayout'

class ReviewView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'ReviewView'

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXAlign = new Transitionable(0)

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    ReviewStore.on Constants.stores.CARD_CHANGE, @loadCard
    ReviewStore.on Constants.stores.COMMENTS_CHANGE, @loadComments

  initViews: ->

    ## CARD ##
    @cardView = new CardView card.id, card, size: [Utils.getViewportWidth(), null]
    @cardViewMod = new Modifier
      align: =>
        xAlign = @cardXAlign.get()
        yAlign = @_translateToAlign @cardYPos.get()
        [xAlign, yAlign]
      origin: @options.cards.origin
    @add(@cardViewMod).add @cardView

    ## NAV ##
    @navView = new ReviewNavView
    @navView._eventOutput.on 'back', =>
      ReviewActions.back()
    @add(@navView)

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
      isMovingY = false;
      isMovingX = false;
    ).bind(@)

  loadCard: =>
    card = ReviewStore.getCard()
    @cardView.load card
    @cardView.on 'comment', =>
      @collapseComments()
    @cardView.pipe @

    @navView.setOptions {
      'cardType': 'review'
      'message': ReviewStore.getMessage()
    }


  loadComments: =>
    @comments.load ReviewStore.getComments()

  saveComment: (comment) ->
    ReviewActions.comment(comment)

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


module.exports = ReviewView
