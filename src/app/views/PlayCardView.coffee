require './scss/play.scss'

View = require 'famous/core/View'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
Transform = require 'famous/core/Transform'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'
Timer = require 'famous/utilities/Timer'
Transitionable = require 'famous/transitions/Transitionable'
Utils = require 'lib/Utils'
Constants = require 'constants/PeggConstants'
PlayStore = require 'stores/PlayStore'
PlayActions = require 'actions/PlayActions'

CardView = require 'views/CardView'
CommentsView = require 'views/CommentsView'
InputView = require 'views/InputView'
PlayNavView = require 'views/PlayNavView'
LayoutManager = require 'views/layouts/LayoutManager'

RenderController = require 'famous/views/RenderController'
Easing = require 'famous/transitions/Easing'

class PlayCardView extends View

  constructor: (options) ->
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'PlayView'

    @_viewportHeight = Utils.getViewportHeight()
    @_viewportWidth = Utils.getViewportWidth()

    # create transitionable with initial value of 0
    @cardYPos = new Transitionable(0)
    @cardXAlign = new Transitionable(0)

    @initViews()
    @initListeners()
    @initGestures()

  initListeners: ->
    PlayStore.on Constants.stores.PREF_SAVED, @cardPref
    PlayStore.on Constants.stores.CARD_FAIL, @cardFail
    PlayStore.on Constants.stores.CARD_WIN, (points) =>
      @cardWin points
    PlayStore.on Constants.stores.COMMENTS_CHANGE, @loadComments
    @cardView.on 'comment', =>
      @collapseComments()
    @cardView.on 'pegg', (payload) =>
      PlayActions.pegg payload.peggeeId, payload.id, payload.choiceId, payload.answerId
    @cardView.on 'pref', (payload) =>
      PlayActions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
    @cardView.on 'plug', (payload) =>
      PlayActions.plug payload.id, payload.full, payload.thumb
    @cardView.pipe @

  initViews: ->

    ## CARDS ##
    @cardView = new CardView
    @cardViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        [@layout.cards.align[0], @layout.cards.align[1] + yAlign]
      origin: @layout.cards.origin
    @add(@cardViewMod).add @cardView

    ## NAV ##
    @navView = new PlayNavView
    @navView._eventOutput.on 'click', (data) =>
      if data is 'prevPage'
        @prevPage()
      else if data is 'nextPage'
        @nextPage()
    @add(@navView)
    @navView.hideRightArrow()

    ## COMMENTS ##
    @comments = new CommentsView
    @newComment = new InputView
      size: @layout.newComment.size
      placeholder: "Enter a comment..."
      align: @layout.newComment.states[1].align
      origin: @layout.newComment.origin
    @newCommentMod = new StateModifier
      align: @layout.newComment.align
      origin: @layout.newComment.origin
    @add(@newCommentMod).add @newComment
    @newComment.on 'submit', (comment) =>
      @newComment.setValue ''
      @saveComment comment

    @numComments = new Surface
      size: @layout.numComments.size
      content: "x comments..."
      classes: ['comments__text', 'comments__num']
    @numCommentsMod = new StateModifier
      align: @layout.numComments.align
      origin: @layout.numComments.origin
    @add(@numCommentsMod).add @numComments
    @numComments.on 'click', =>
      @expandComments()
    @hideComments()

    @rc = new RenderController
      inTransition:  { duration: 500, curve: Easing.outCubic }
      outTransition: { duration: 350, curve: Easing.outCubic }
#    @rc.inTransformFrom -> Transform.translate 0, Utils.getViewportHeight(), 0
#    @rc.outTransformFrom -> Transform.translate 0, Utils.getViewportHeight(), 0
    @rc.hide(@comments)
    @rcMod = new StateModifier
      align: @layout.comments.align
      origin: @layout.comments.origin
    @add(@rcMod).add @rc


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

    minVelocity = 0.5
    minDelta = 100

    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'card:flipped', (card) =>
      @collapseComments() if @_commentsIsExpanded

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
        max = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
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
      isMovingY = false
    ).bind(@)


  load: (card) =>
    @cardView.loadCard card, 'play'

  loadComments: =>
    @comments.load PlayStore.getComments()

  nextPage: =>
    PlayActions.nextPage()
    @navView.hideRightArrow()
    @hideComments()

  prevPage: =>
    PlayActions.prevPage()

  cardPref: =>
    @showComments()
    @navView.showRightArrow()

  cardFail: =>
    #@message.setClasses ['card__message__fail']
    #@message.setContent PlayStore.getMessage('fail')

  cardWin: (points) =>
    @showPoints points
    @showComments()
    @navView.showRightArrow()

  showPoints: (points) =>
    console.log "points: #{points}"
    @points.setContent "+#{points}"
    Utils.animateAll @pointsMod, @layout.points.states

  showComments: =>
    @numComments.setContent "#{@comments.getCount()} comments."
    Utils.animate @numCommentsMod, @layout.numComments.states[0]
#    @rc.show(@comments)

  hideComments: =>
    Utils.animate @numCommentsMod, @layout.numComments.states[1]
#    @newComment.setAlign @layout.newComment.states[0].align
#    @rc.hide(@comments)

  saveComment: (comment) ->
    # FIXME need cardId, peggeeID
    PlayActions.comment(comment, cardId, peggeeId)

  collapseComments: =>
    @rc.hide(@comments)
    @navView.showNav()
    # slide the cards down to their starting position
    @cardYPos.set(0, @layout.cards.states[0].transition)
    # slide the comments down to their starting position
    Utils.animate @numCommentsMod, @layout.numComments.states[0]
    @._commentsIsExpanded = false
    @newComment.setAlign @layout.newComment.states[0].align

  expandComments: =>
    @rc.show(@comments)
    @navView.hideNav()
    maxCardYPos = @layout.cards.states[1].align[1] * Utils.getViewportHeight()
    # move the cards up
    @cardYPos.set(maxCardYPos, @layout.cards.states[1].transition)
    # slide the comments up
    Utils.animate @numCommentsMod, @layout.numComments.states[1]
    @._commentsIsExpanded = true
    @newComment.setAlign @layout.newComment.states[1].align


  _translateToAlign: (delta, axis) =>
    if axis is 'Y'
      delta / @_viewportHeight
    else if axis is 'X'
      delta / @_viewportWidth
    else
      null

module.exports = PlayCardView
