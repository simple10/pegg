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
NavActions = require 'actions/NavActions'
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

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    ReviewStore.on Constants.stores.CARD_CHANGE, @loadCard
    ReviewStore.on Constants.stores.COMMENTS_CHANGE, @loadComments

  initViews: ->

    ## CARD ##
    @cardView = new CardView
      size: [window.innerWidth, null]
      type: 'review'
    @cardViewMod = new Modifier
      align: =>
        yAlign = @cardYPos.get() / Utils.getViewportHeight()
        [@layout.card.align[0], @layout.card.align[1] + yAlign]
      origin: @layout.card.origin
    @add(@cardViewMod).add @cardView

    ## NAV ##
    @navView = new ReviewNavView
    @navView._eventOutput.on 'back', =>
      NavActions.back()
    @add(@navView)

    ## COMMENTS ##
    @comments = new CommentsView
    @commentsMod = new StateModifier
      align: @layout.comments.align
      origin: @layout.comments.origin
      transform: Transform.translate null, null, -3
    @add(@commentsMod).add @comments
    
    @comments.on 'open', =>
      @expandComments()

    @newComment = new InputView
      size: @layout.newComment.size
      placeholder: 'Enter a comment...'
      align: @layout.newComment.states[1].align
      origin: @layout.newComment.origin
    @newCommentMod = new StateModifier
      align: @layout.newComment.align
      origin: @layout.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.setValue ''
      @saveComment comment

    @collapseComments()

  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    minVelocity = 0.5
    minDelta = 100

    @sync = new GenericSync ['mouse', 'touch']
    @_eventInput.pipe @sync

    isMovingY = false
    startPos = 0

    @sync.on 'start', (data) =>
      startPos = @cardYPos.get()

    @sync.on 'update', ((data) ->
      dy = data.delta[1]
      if !isMovingY
        if Math.abs(dy) > 0
          isMovingY = true
      if isMovingY
        currentPosition = @cardYPos.get()
#        console.log 'currentPosition', currentPosition
        # calculate the max Y offset to prevent the user from being able
        # to drag the card past this point
        max = @layout.card.states[1].align[1] * Utils.getViewportHeight()
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
      # reset axis movement flags
      isMovingY = false;
    ).bind(@)

  loadCard: =>
    card = ReviewStore.getCard()
    @cardView.loadCard card.id, card
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
    @cardYPos.set(0, @layout.card.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @commentsMod, @layout.comments.states[1]
    @._commentsIsExpanded = false;
    @newComment.setAlign @layout.newComment.states[0].align

  expandComments: =>
    maxCardYPos = @layout.card.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @layout.card.states[1].transition)
    # slide the comments up
    Utils.animate @commentsMod, @layout.comments.states[2]
    @._commentsIsExpanded = true;
    @newComment.setAlign @layout.newComment.states[1].align

module.exports = ReviewView
