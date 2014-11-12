require './scss/play.scss'
_ = require('Parse')._

# Famo.us
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
Easing = require 'famous/src/transitions/Easing'
GenericSync = require 'famous/src/inputs/GenericSync'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier = require 'famous/src/core/Modifier'
MouseSync = require 'famous/src/inputs/MouseSync'
RenderController = require 'famous/src/views/RenderController'
RenderNode = require 'famous/src/core/RenderNode'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Timer = require 'famous/src/utilities/Timer'
TouchSync = require 'famous/src/inputs/TouchSync'
Transform = require 'famous/src/core/Transform'
Transitionable = require 'famous/src/transitions/Transitionable'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
AppStateStore = require 'stores/AppStateStore'
CardStore = require 'stores/CardStore'
CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
Constants = require 'constants/PeggConstants'
InputView = require 'views/InputView'
LayoutManager = require 'views/layouts/LayoutManager'
MessageActions = require 'actions/MessageActions'
NavActions = require 'actions/NavActions'
PlayActions = require 'actions/PlayActions'
PlayStore = require 'stores/PlayStore'
SingleCardActions = require 'actions/SingleCardActions'
SingleCardStore = require 'stores/SingleCardStore'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'


class PlayCardView extends View

  constructor: (options) ->
    super options

    @_context = options.context
    if @_context is 'play'
      @_store = PlayStore
      @_actions = PlayActions
    else if @_context is 'single_card'
      @_store = SingleCardStore
      @_actions = SingleCardActions

    @_canComment    = false
    @_canCreateCard = false
    @_canFlip       = false
    @_canGoForward  = false
    @_canGoBack     = false

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    @_viewportHeight = Utils.getViewportHeight()
    @_viewportWidth = Utils.getViewportWidth()

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXPos = new Transitionable(0)

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    @_store.on Constants.stores.CARD_CHANGE, @loadSingleCard
    @_store.on Constants.stores.CARD_FAIL, @cardFail
    @_store.on Constants.stores.CARD_WIN, @cardWin
    @_store.on Constants.stores.PAGE_CHANGE, @loadPlay
    @_store.on Constants.stores.PREF_SAVED, @cardPref
    @_store.on Constants.stores.REQUIRE_LOGIN, @requireLogin
#    AppStateStore.on Constants.stores.MENU_CHANGE, @

    @cardView.on 'comment', =>
      @collapseComments()
    @cardView.on 'showComments', =>
      @expandComments()
    @cardView.on 'pegg', (payload) =>
      @_actions.pegg payload.peggeeId, payload.id, payload.choiceId, payload.answerId
    @cardView.on 'pref', (payload) =>
      @_actions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
      @_canFlip = true
    @cardView.on 'plug', (payload) =>
      @_actions.plug payload.id, payload.full, payload.thumb
    @cardView.on 'win', (payload) =>
      @_canFlip = true
    @cardView.pipe @

  initViews: ->
    ## CARD ##
    @cardView = new CardView
    cardViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        xAlign = @_translateToAlign @cardXPos.get(), 'X'
        [@layout.cards.align[0] + xAlign, @layout.cards.align[1] + yAlign]
      origin: @layout.cards.origin
    @add(cardViewMod).add @cardView

    ## COMMENTS ##
    @commentsView = new CommentsView
    @commentsViewRc = new RenderController
      inTransition:  @layout.comments.inTransition
      outTransition: @layout.comments.outTransition
    commentsViewMod = new StateModifier
      align: @layout.comments.align
      origin: @layout.comments.origin
    @add(commentsViewMod).add @commentsViewRc

    @numComments = new Surface
      size: @layout.numComments.size
      content: "x comments..."
      classes: ['comments__text', 'comments__num']
    @numCommentsRc = new RenderController
      inTransition: @layout.numComments.inTransition
      outTransition: @layout.numComments.outTransition
      overlap: false
    numCommentsMod = new StateModifier
      align: @layout.numComments.align
      origin: @layout.numComments.origin
    @add(numCommentsMod).add @numCommentsRc
    @numComments.on 'click', =>
      @expandComments() if @_canComment
    @hideNumComments()

    @newComment = new InputView
      size: @layout.newComment.size
      placeholder: "Enter a comment..."
    @newCommentNode = new RenderNode new StateModifier
      transform: @layout.newComment.transform
    @newCommentNode.add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.clear()
      @saveComment comment

    ## NEW CARD ##
    @newCardButton = new ImageSurface
      size: @layout.newCard.size
      content: @layout.newCard.content
      classes: @layout.newCard.classes
    @newCardButton.on 'click', ->
      NavActions.selectMenuItem 'create'
    @newCardButtonRc = new RenderController
      inTransition:  @layout.newCard.inTransition
      outTransition: @layout.newCard.outTransition
    newCardButtonMod = new StateModifier
      align: @layout.newCard.align
      origin: @layout.newCard.origin
      transform: @layout.newCard.transform
    @add(newCardButtonMod).add @newCardButtonRc

    ## POINTS ##
    @points = new Surface
      size: @layout.points.size
      classes: @layout.points.classes
    @pointsMod = new Modifier
      align: @layout.points.align
      origin: @layout.points.origin
      transform: @layout.points.transform
    @add(@pointsMod).add @points

  initGestures: ->
    GenericSync.register mouse: MouseSync
    GenericSync.register touch: TouchSync

    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'card:flipped', (card) =>
      @collapseComments() if @_commentsExpanded
      @collapseNewCard() if @_newCardExpanded

    @_eventInput.pipe @sync

    minVelocity = 0.5
    minDelta = 10                                                                  # pixels
    deltaWithVelocityThreshold = 60                                                # pixels
    deltaWithoutVelocityThreshold = 200                                            # pixels
    flipWithVelocityThreshold = 0.25                                               # radians
    flipWithoutVelocityThreshold = 0.51                                            # radians
    topYPosition = Utils.getViewportHeight() * @layout.cards.states[1].align[1]    # pixels
    bottomYPosition = Utils.getViewportHeight() * @layout.cards.states[2].align[1] # pixels
    originalYPosition = 0                                                          # pixels
    lockedAxis = null
    hasMovedX = false
    hasMovedY = false
    flipping = false
    x = 0
    y = 0

    easeIn = (time, initialValue, changeInValue, duration) ->
      time /= duration
      changeInValue * time*time*time + initialValue

    @sync.on 'start', (data) =>

    @sync.on 'update', (data) =>
      x = data.position[0]
      y = data.position[1]

      # establish primary direction of movement
      if Math.abs(y) > Math.abs(x)
        primaryDirection = 'Y'
      else
        primaryDirection = 'X'

      # lock travel on one axis
      if not lockedAxis
        if primaryDirection is 'Y' and Math.abs(y) > minDelta
          lockedAxis = 'Y'
        else if primaryDirection is 'X' and Math.abs(x) > minDelta
          lockedAxis = 'X'

      # up/down movement
      if Math.abs(y) > 0 and lockedAxis isnt 'X'
        hasMovedY = true
        hasMovedX = false
        # calculate the max Y offset to prevent the user from being able to drag the card past this point
        yPosition = y
        if @_commentsExpanded
          # starting from comments expanded position, so need to offset it
          yPosition = y + topYPosition
          # can't move down past original position
          if yPosition > originalYPosition
            yPosition = originalYPosition
          # can't move up anymore
          else if yPosition < topYPosition
            yPosition = topYPosition
        else if @_newCardExpanded
          # starting from new card position, so need to offset it
          yPosition = y + bottomYPosition
          # can't move up past original position
          if yPosition < originalYPosition
            yPosition = originalYPosition
          # can't move down anymore
          else if yPosition > bottomYPosition
            yPosition = bottomYPosition
        else # starting from original position
          if y > bottomYPosition
            yPosition = bottomYPosition
          else if not @_canComment and y < originalYPosition
            yPosition = originalYPosition
          else if not @_canCreateCard and y > originalYPosition
            yPosition = originalYPosition
          else if y < topYPosition
            yPosition = topYPosition
        @cardYPos.set yPosition
        @snapToOrigin 'X'

      # left/right movement
      if Math.abs(x) > 0 and lockedAxis isnt 'Y' and not (@_commentsExpanded or @_newCardExpanded)
        hasMovedX = true
        hasMovedY = false
        if @_canFlip
          flipping = true
          radians = ( -x / Utils.getViewportWidth() ) * 2
          radians += @cardView.currentSide
          if radians > 1
            # not actually flipping, drag instead
            if @cardView.currentSide is 1 and @_canGoForward
              @cardXPos.set x
              flipping = false
              radians = 1
            # can't drag, so give some springy feedback
            else
              easy = easeIn(radians, 1, 1, 4)
              radians = Math.min easy, 1.2
          else if radians < 0
            # not actually flipping, drag instead
            if @cardView.currentSide is 0 and @_canGoBack
              @cardXPos.set x
              flipping = false
              radians = 0
            # can't drag, so give some springy feedback
            else
              easy = -easeIn(1 - radians, 0, 1, 4)
              radians = Math.max easy, -0.2
          @cardView.flipTransition.set -radians
        else
          @cardXPos.set x
        @snapToOrigin 'Y'

    @sync.on 'end', (data) =>
      # retrieve the velocity
      xVelocity = data.velocity[0]
      yVelocity = data.velocity[1]
      # retrieve the total position change
      x = data.position[0]
      y = data.position[1]
      movingDown  = y > 0
      movingUp    = y < 0
      movingLeft  = x < 0
      movingRight = x > 0
      radians = ( -x / Utils.getViewportWidth() ) * 2

      if hasMovedX
        # establish whether we've crossed threshold
        crossedXThreshold = false
        if flipping
          # flipping left/right and crossed min pos and vel threshold
          if Math.abs(radians) > flipWithVelocityThreshold && Math.abs(xVelocity) > minVelocity
            crossedXThreshold = true
          # flipping left/right and crossed max pos threshold
          else if Math.abs(radians) > flipWithoutVelocityThreshold
            crossedXThreshold = true
          # otherwise threshold not met, so return to original position
          else
            @cardView.flipTransition.set -@cardView.currentSide, @cardView.layout.card.transition
        else
          # swiping/dragging left/right and crossed min pos and vel threshold
          if Math.abs(x) > deltaWithVelocityThreshold && Math.abs(xVelocity) > minVelocity
            crossedXThreshold = true
          # swiping/dragging left/right and crossed max pos threshold
          else if Math.abs(x) > deltaWithoutVelocityThreshold
            crossedXThreshold = true
          # otherwise threshold not met, so return to original position
          else
            @snapToOrigin 'X'

        # if we've crossed the threshold then we want to finish flipping or dragging
        # the card, and if dragging, go to next/prev page
        if crossedXThreshold
          if movingLeft
            if flipping and @cardView.currentSide is 0
              @cardView.flipTransition.set -1, @cardView.layout.card.transition
              @cardView.currentSide = 1
            else if @_canGoForward
              offscreenLeft = -Utils.getViewportWidth()
              @cardXPos.set(offscreenLeft, @layout.cards.states[0].transition)
              @nextPage()
            else
              # return to original position
              @cardView.flipTransition.set -@cardView.currentSide, @cardView.layout.card.transition
          else if movingRight
            if flipping and @cardView.currentSide is 1
              @cardView.flipTransition.set 0, @cardView.layout.card.transition
              @cardView.currentSide = 0
            else if @_canGoBack
              offscreenRight = Utils.getViewportWidth()
              @cardXPos.set(offscreenRight, @layout.cards.states[0].transition)
              @prevPage()
            else
              # return to original position
              @cardView.flipTransition.set -@cardView.currentSide, @cardView.layout.card.transition
      else
        @snapToOrigin 'X'

      # figure out if we need to show/hide the comments if moving along the Y axis
      if hasMovedY
        crossedYThreshold = false
        # swiping/dragging up/down and crossed min pos and vel threshold
        if Math.abs(y) > deltaWithVelocityThreshold && Math.abs(yVelocity) > minVelocity
          crossedYThreshold = true
        # swiping/dragging up/down and crossed max pos threshold
        else if Math.abs(y) > deltaWithoutVelocityThreshold
          crossedYThreshold = true
        else if Math.abs(y)
          # otherwise threshold not met, so return to original position
          if @_commentsExpanded and movingDown
            @expandComments()
          else if @_newCardExpanded and movingUp
            @expandNewCard()
          else
            @snapToOrigin 'Y'

        if crossedYThreshold
          if movingDown
            if @_commentsExpanded
              @collapseComments()
            else if @_canCreateCard
              @expandNewCard()
          else if movingUp
            if @_newCardExpanded
              @collapseNewCard()
            else if @_canComment
              @expandComments()

      # reset movement flags
      hasMovedX = false
      hasMovedY = false
      lockedAxis = null
      flipping = false

  loadSingleCard: =>
    @_referrer = SingleCardStore.getReferrer()
    @_canGoForward = false
    @_canGoBack = if @_referrer? then true else false
    card = @_store.getCard()
    @_load card

  loadPlay: =>
    @_canGoForward = true
    @_canGoBack    = true
    page = @_store.getCurrentPage()
    if page.type is 'card'
      @_load page.card

  _load: (card) =>
    @_canFlip       = false
    @_canComment    = false
    @_canCreateCard = true
#    @snapToOrigin 'X', 0
    @card = card
    @cardView.loadCard card
    if card.type is 'deny'
      @hideNumComments()
      @_canFlip = true
      @_canComment = false
      @_canCreateCard = false
    else if card.type is 'review'
      @loadComments()
      @showNumComments()
      @_canFlip = true
      @_canComment = true
    else
      @loadComments()

  loadComments: =>
    @commentsView.load @card.comments
    @numComments.setContent "#{@commentsView.getCount()} comments."

  nextPage: =>
    @_eventOutput.emit 'forward'
    @_actions.nextPage()
    @hideNumComments()

  prevPage: =>
    @_eventOutput.emit 'back'
    @_actions.prevPage()

  cardPref: =>
    @showNumComments()
    @_canComment = true

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent @_store.getMessage('fail')

  cardWin: (points) =>
    @showPoints points
    @showNumComments()
    @_canComment = true

  showPoints: (points) =>
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showNumComments: =>
    @numCommentsRc.show @numComments

  hideNumComments: =>
    @_canComment = false
    @numCommentsRc.hide @numComments
#    @newComment.setAlign @layout.newComment.states[0].align

  saveComment: (comment) ->
    @_actions.comment comment, @card.id, @card.peggeeId
    newComment =
      userImg: UserStore.getAvatar 'type=square'
      text: comment
    if @card.comments? and @card.comments.length > 0
      @card.comments.unshift newComment
    else
      @card.comments = [newComment]
    @loadComments()

  collapseComments: =>
    @commentsViewRc.hide @commentsView
    # slide the card down to their starting position
    @snapToOrigin 'Y'
    # slide the comments down to their starting position
    @numCommentsRc.show @numComments
    @_commentsExpanded = false

  expandComments: =>
    @commentsViewRc.show @commentsView
    topYPos = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the card up to comments showing position
    @cardYPos.set(topYPos, @layout.cards.states[1].transition)
    # slide the comments up
    @numCommentsRc.show @newCommentNode
    @_commentsExpanded = true

  collapseNewCard: =>
    @newCardButtonRc.hide @newCardButton
    # slide the card up to its starting position
    @snapToOrigin 'Y'
    @_newCardExpanded = false

  expandNewCard: =>
    @newCardButtonRc.show @newCardButton
    bottomYPos = @layout.cards.states[2].align[1] * Utils.getViewportHeight()
    # move the card down to new card position
    @cardYPos.set(bottomYPos, @layout.cards.states[2].transition)
    @_newCardExpanded = true

  snapToOrigin: (axis, duration) =>
    # slide the cards back to their starting position
    transition = _.extend {}, @layout.cards.states[0].transition
    transition.duration = duration if duration?
    switch axis
      when 'Y'
        @cardYPos.set(0, transition)
      when 'X'
        @cardXPos.set(0, transition)

  requireLogin: =>
    MessageActions.show 'app__login_required'

  _translateToAlign: (delta, axis) =>
    if axis is 'Y'
      delta / @_viewportHeight
    else if axis is 'X'
      delta / @_viewportWidth
    else
      null

module.exports = PlayCardView
