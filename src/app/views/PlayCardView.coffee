require './scss/play.scss'

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
CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
Constants = require 'constants/PeggConstants'
InputView = require 'views/InputView'
LayoutManager = require 'views/layouts/LayoutManager'
MessageActions = require 'actions/MessageActions'
NavActions = require 'actions/NavActions'
PlayActions = require 'actions/PlayActions'
PlayNavView = require 'views/PlayNavView'
PlayStore = require 'stores/PlayStore'
SingleCardActions = require 'actions/SingleCardActions'
SingleCardStore = require 'stores/SingleCardStore'
AppStateStore = require 'stores/AppStateStore'
UserStore = require 'stores/UserStore'
CardStore = require 'stores/CardStore'
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

    @_commentable = false
    @_flippable = false

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
    @cardView.on 'pegg', (payload) =>
      @_actions.pegg payload.peggeeId, payload.id, payload.choiceId, payload.answerId
      @_flippable = true
    @cardView.on 'pref', (payload) =>
      @_actions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
      @_flippable = true
    @cardView.on 'plug', (payload) =>
      @_actions.plug payload.id, payload.full, payload.thumb
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

    ## PLAY NAV ##
    @playNavView = new PlayNavView
    @add @playNavView
    @playNavView._eventOutput.on 'click', (data) =>
      if data is 'prevPage'
        @prevPage()
      else if data is 'nextPage'
        @nextPage()
      else if data is 'back'
        NavActions.selectMenuItem @_referrer
    @playNavView.hideRightArrow()

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
      @expandComments() if @_commentable
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
    @newCardView = new ImageSurface
      size: @layout.newCard.size
      content: @layout.newCard.content
      classes: @layout.newCard.classes
    @newCardViewRc = new RenderController
      inTransition:  @layout.newCard.inTransition
      outTransition: @layout.newCard.outTransition
    newCardViewMod = new StateModifier
      align: @layout.newCard.align
      origin: @layout.newCard.origin
      transform: @layout.newCard.transform
    @add(newCardViewMod).add @newCardViewRc

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

    minDelta = 10
    minVelocity = 0.5
    deltaWithVelocityThreshold = 60
    deltaWithoutVelocityThreshold = 200
    topYPosition = Utils.getViewportHeight() * @layout.cards.states[1].align[1]
    bottomYPosition = Utils.getViewportHeight() * @layout.cards.states[2].align[1]
    originalYPosition = 0
    lockedToAxis = null
    hasMovedX = false
    hasMovedY = false
    x = 0
    y = 0

    @sync.on 'start', (data) =>

    @sync.on 'update', (data) =>
      x = data.position[0]
      y = data.position[1]
      if Math.abs(y) > Math.abs(x)
        primaryDirection = 'Y'
      else
        primaryDirection = 'X'

      if not lockedToAxis
        if primaryDirection is 'Y' and Math.abs(y) > minDelta
          lockedToAxis = 'Y'
        else if primaryDirection is 'X' and Math.abs(x) > minDelta
          lockedToAxis = 'X'

      if Math.abs(y) > 0 and lockedToAxis isnt 'X'
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
          else if not @_commentable and y < originalYPosition
            yPosition = originalYPosition
          else if y < topYPosition
            yPosition = topYPosition
        @cardYPos.set yPosition
        @snapToOrigin 'X'

      if @_context is 'play' and Math.abs(x) > 0 and lockedToAxis isnt 'Y' and not (@_commentsExpanded or @_newCardExpanded)
        hasMovedX = true
        hasMovedY = false
        if @_flippable
          radians = ( -x / Utils.getViewportWidth() ) * 2
          radians += @cardView.currentSide
          if radians > 1
            radians = 1
            @cardXPos.set x if @cardView.currentSide is 1
          else if radians < 0
            radians = 0
            @cardXPos.set x if @cardView.currentSide is 0
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
      movingDown = y > 0
      movingUp   = y < 0

      if hasMovedX
        crossedXThreshold = false

        # swiping/dragging up and crossed min pos and vel threshold
        if Math.abs(x) > deltaWithVelocityThreshold && Math.abs(xVelocity) > minVelocity
          crossedXThreshold = true
        # swiping/dragging up and crossed max pos threshold
        else if Math.abs(x) > deltaWithoutVelocityThreshold
          crossedXThreshold = true
        # otherwise threshold not met, so return to original position
        else if Math.abs(x)
          @cardView.flipTransition.set -@cardView.currentSide, @cardView.layout.card.transition
          @snapToOrigin 'X'

        if crossedXThreshold
          if x < 0
            if @_flippable and @cardView.currentSide is 0
              @cardView.flipTransition.set -1, @cardView.layout.card.transition
              @cardView.currentSide = 1
            else
              offscreenLeft = -Utils.getViewportWidth()
              @cardXPos.set(offscreenLeft, @layout.cards.states[1].transition)
              @nextPage()
          else if x > 0
            if @_flippable and @cardView.currentSide is 1
              @cardView.flipTransition.set 0, @cardView.layout.card.transition
              @cardView.currentSide = 0
            else
              offscreenRight = Utils.getViewportWidth()
              @cardXPos.set(offscreenRight, @layout.cards.states[1].transition)
              @prevPage()
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

        if crossedYThreshold
          console.log "crossed Y threshold"
          if movingDown
            if @_commentsExpanded
              @collapseComments()
            else
              @expandNewCard()
          else if movingUp
            if @_newCardExpanded
              @collapseNewCard()
            else if @_commentable
              @expandComments()

      # reset axis movement flags
      hasMovedX = false
      hasMovedY = false
      lockedToAxis = null

  loadSingleCard: =>
    @playNavView.showSingleCardNav()
    card = @_store.getCard()
    @_load card
# MAYBE: set options??
#   @playNavView.setOptions {
#     'cardType': card.type
#   }
#    if referrer?
#      @playNavView.showLeftArrow()
#    else
#      @playNavView.hideLeftArrow()
#      @hideNumComments()

  _load: (card) =>
    @_flippable = false
    @snapToOrigin 'X'
    @card = card
    @cardView.loadCard card
    if card.type is 'deny'
      @hideNumComments()
      @_flippable = true
    else if card.type is 'review'
      @loadComments()
      @showNumComments()
      @_flippable = true
    else
      @loadComments()

  loadPlay: =>
    page = @_store.getCurrentPage()
    if page.type is 'card'
      @playNavView.showPlayNav()
      @_load page.card

  loadComments: =>
    @commentsView.load @card.comments
    @numComments.setContent "#{@commentsView.getCount()} comments."

  nextPage: =>
    @_actions.nextPage()
    @playNavView.hideRightArrow()
    @hideNumComments()

  prevPage: =>
    @_actions.prevPage()

  cardPref: =>
    @showNumComments()
    @playNavView.showRightArrow() if @_context is 'play'

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent @_store.getMessage('fail')

  cardWin: (points) =>
    @showPoints points
    @showNumComments()
    @playNavView.showRightArrow() if @_context is 'play'

  showPoints: (points) =>
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showNumComments: =>
    @_commentable = true
    @numCommentsRc.show @numComments

  hideNumComments: =>
    @_commentable = false
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
    @playNavView.showNav()
    # slide the card down to their starting position
    @snapToOrigin 'Y'
    # slide the comments down to their starting position
    @numCommentsRc.show @numComments
    @_commentsExpanded = false

  expandComments: =>
    @commentsViewRc.show @commentsView
    @playNavView.hideNav()
    topYPos = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the card up to comments showing position
    @cardYPos.set(topYPos, @layout.cards.states[1].transition)
    # slide the comments up
    @numCommentsRc.show @newCommentNode
    @_commentsExpanded = true

  collapseNewCard: =>
    @newCardViewRc.hide @newCardView
    # slide the card up to its starting position
    @snapToOrigin 'Y'
    @_newCardExpanded = false

  expandNewCard: =>
    @newCardViewRc.show @newCardView
    bottomYPos = @layout.cards.states[2].align[1] * Utils.getViewportHeight()
    # move the card down to new card position
    @cardYPos.set(bottomYPos, @layout.cards.states[2].transition)
    @_newCardExpanded = true

  snapToOrigin: (axis) =>
    # slide the cards back to their starting position
    switch axis
      when 'Y'
        @cardYPos.set(0, @layout.cards.states[0].transition)
      when 'X'
        @cardXPos.set(0, @layout.cards.states[0].transition)

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
