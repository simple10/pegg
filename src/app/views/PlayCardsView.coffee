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

class PlayCardsView extends View

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
    PlayStore.on Constants.stores.CARDS_CHANGE, @loadCards
    PlayStore.on Constants.stores.CHOICES_CHANGE, (payload) =>
      @loadChoices payload.cardId, payload.choices

  initViews: ->

    ## CARDS ##
    @cardScrollView = new Scrollview
      direction: Utility.Direction.X
      paginated: true
      margin: 300
    @cardScrollViewMod = new Modifier
      align: =>
        yAlign = @_translateToAlign @cardYPos.get(), 'Y'
        [@layout.cards.align[0], @layout.cards.align[1] + yAlign]
      origin: @layout.cards.origin
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

    onEdgeEnd = false
    minVelocity = 0.5
    minDelta = 100
    choicesShowing = false
    @sync = new GenericSync ['mouse', 'touch']

    @_eventInput.on 'choices:showing', (card) =>
      choicesShowing = true
      @collapseComments() if @_commentsIsExpanded
      @_unpipeCardsToScrollView()

    @_eventInput.on 'choices:hidden', (card) =>
      choicesShowing = false
      @collapseComments() if @_commentsIsExpanded
      @_pipeCardsToScrollView()

    @_eventInput.on 'card:flipped', (card) =>
      choicesShowing = false
      @collapseComments() if @_commentsIsExpanded
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
        size: [Utils.getViewportWidth(), Utils.getViewportHeight()]
      card.loadCard cardId, cardObj, 'play'
      card.on 'comment', =>
        @collapseComments()
      card.on 'pegg', (payload) =>
        PlayActions.pegg payload.peggee, payload.id, payload.choiceId, payload.answerId
      card.on 'pref', (payload) =>
        PlayActions.pref payload.id, payload.choiceId, payload.plug, payload.thumb
      card.on 'plug', (payload) =>
        PlayActions.plug payload.id, payload.full, payload.thumb
      card.pipe @
      @cardViews.push card
      @index[cardId] = i++

    @_pipeCardsToScrollView()
    @navView.setOptions {
      'cardType': PlayStore.getCurrentCardsType()
      'firstName': name
    }

  loadChoices: (cardId, choices) =>
    @cardViews[@index[cardId]].loadChoices choices

  loadComments: =>
    @comments.load PlayStore.getComments()

  nextCard: (triggerPageChange) =>
    if triggerPageChange
      if @cardScrollView._node.index isnt PlayStore.getSetLength() - 1
        # tapped next button and not at end of card set
        @cardScrollView.goToNextPage()

    PlayActions.nextCard()
    @navView.hideRightArrow()
    @hideComments()

  prevCard: (triggerPageChange) =>
    if triggerPageChange
      @cardScrollView.goToPreviousPage()
      console.log @cardScrollView.getCurrentIndex()
    else PlayActions.prevCard()

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

  _pipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].pipe @cardScrollView
    null

  _unpipeCardsToScrollView: () =>
    for i of @cardViews
      @cardViews[i].unpipe @cardScrollView
    null

  _translateToAlign: (delta, axis) =>
    if axis is 'Y'
      delta / @_viewportHeight
    else if axis is 'X'
      delta / @_viewportWidth
    else
      null

module.exports = PlayCardsView
