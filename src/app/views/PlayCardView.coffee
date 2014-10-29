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

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    @_viewportHeight = Utils.getViewportHeight()
    @_viewportWidth = Utils.getViewportWidth()

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)

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
    @cardView.on 'pref', (payload) =>
      @_actions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
    @cardView.on 'plug', (payload) =>
      @_actions.plug payload.id, payload.full, payload.thumb
    @cardView.pipe @

  initViews: ->
    ## CARD ##
    @cardView = new CardView
    cardViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        [@layout.cards.align[0], @layout.cards.align[1] + yAlign]
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
      inTransition:  { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
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

    # minDelta = 10
    minVelocity = 0.5
    deltaYWithVelocityThreshold = 60
    deltaYWithoutVelocityThreshold = 200
    maxYPosition = @layout.cards.states[1].align[1] * Utils.getViewportHeight()

    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'card:flipped', (card) =>
      @collapseComments() if @_commentsExpanded

    @_eventInput.pipe @sync

    isMovingX = false
    isMovingY = false
    startYPos = 0
    dx = dy = 0

    @sync.on 'start', (data) =>
      startYPos = @cardYPos.get()
      @cardView.preventFlip = true

    @sync.on 'update', ((data) ->
      dx = data.delta[0]
      dy = data.delta[1]

      if @_commentable and Math.abs(dy) > 0 and Math.abs(dy) > Math.abs(dx)
        isMovingX = false
        isMovingY = true
        currentPosition = @cardYPos.get()
        # calculate the max Y offset to prevent the user from being able
        # to drag the card past this point
        yPos = Math.min Math.abs(maxYPosition), Math.abs(currentPosition + dy)
        @cardYPos.set(-yPos)
      else if @_context is 'play' and Math.abs(dx) > 0 and Math.abs(dx) > Math.abs(dy)
        isMovingX = true
        isMovingY = false
      else
        isMovingX = false
        isMovingY = false

    ).bind(@)

    @sync.on 'end', ((data) ->
      if isMovingX
        if dx < 0
          @nextPage()
        else if dx > 0
          @prevPage()

      # figure out if we need to show/hide the comments if moving along the Y axis
      if isMovingY
        # don't let it flip now, but clear preventFlip for the next time
        setTimeout =>
          @cardView.preventFlip = false
        , 300
        # retrieve the Y velocity
        velocity = data.velocity[1]
        # calculate the total position change
        dy = startYPos - @cardYPos.get()
        # # a tap when card is at the bottom, allowing for some unintentional movement
        # if 0 < dy < minDelta
        #   @cardView.preventFlip = false
        # # a tap when card is at the top, allowing for some unintentional movement
        # else if 0 > dy > -minDelta
        #   @collapseComments()
        # swiping/dragging up and crossed min pos and vel threshold
        if dy > deltaYWithVelocityThreshold && Math.abs(velocity) > minVelocity
          @expandComments()
        # swiping/dragging down and crossed min pos and vel threshold
        else if dy < -deltaYWithVelocityThreshold && Math.abs(velocity) > minVelocity
          @collapseComments()
        # swiping/dragging up and crossed max pos threshold
        else if dy > deltaYWithoutVelocityThreshold
          @expandComments()
        # swiping/dragging down and crossed max pos threshold
        else if dy < -deltaYWithoutVelocityThreshold
          @collapseComments()
        # otherwise threshold not met, so return to original position
        else if dy
          if !@_commentsExpanded then @collapseComments() else @expandComments()
      else if @cardYPos.get() is 0
        # let it flip
        @cardView.preventFlip = false
      else
        @collapseComments()

      # reset axis movement flags
      isMovingX = false
      isMovingY = false
    ).bind(@)

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
    @card = card
    @cardView.loadCard card
    if card.type is 'deny'
      @hideNumComments()
    else if card.type is 'review'
      @loadComments()
      @showNumComments()
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
    # console.log "points: #{points}"
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showNumComments: =>
    # console.log "show number of comments"
    @_commentable = true
    @numCommentsRc.show @numComments

  hideNumComments: =>
    # console.log "hide number of comments"
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
    # console.log "collapse comments"
    @commentsViewRc.hide @commentsView
    @playNavView.showNav()
    # slide the cards down to their starting position
    @cardYPos.set(0, @layout.cards.states[0].transition)
    # slide the comments down to their starting position
    @numCommentsRc.show @numComments
    @_commentsExpanded = false

  expandComments: =>
    # console.log "expand comments"
    @commentsViewRc.show @commentsView
    @playNavView.hideNav()
    maxCardYPos = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @layout.cards.states[1].transition)
    # slide the comments up
    @numCommentsRc.show @newCommentNode
    @_commentsExpanded = true

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
