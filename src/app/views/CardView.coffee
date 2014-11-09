require './scss/card.scss'
_ = require('Parse')._

# Famo.us
Easing = require 'famous/src/transitions/Easing'
GenericSync = require 'famous/src/inputs/GenericSync'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
Modifier = require 'famous/src/core/Modifier'
MouseSync = require 'famous/src/inputs/MouseSync'
RenderController = require 'famous/src/views/RenderController'
StateModifier = require 'famous/src/modifiers/StateModifier'
Surface = require 'famous/src/core/Surface'
Timer = require 'famous/src/utilities/Timer'
TouchSync = require 'famous/src/inputs/TouchSync'
Transform = require 'famous/src/core/Transform'
Utility = require 'famous/src/utilities/Utility'
View = require 'famous/src/core/View'

# Pegg
ChoicesView = require 'views/ChoicesView'
Constants = require 'constants/PeggConstants'
ImagePickView = require 'views/ImagePickView'
LayoutManager = require 'views/layouts/LayoutManager'
UserStore = require 'stores/UserStore'
Utils = require 'lib/Utils'
Transitionable = require 'famous/src/transitions/Transitionable'

class CardView extends View

  constructor: (options) ->
#    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options

    @layoutManager = new LayoutManager()
    @layout = @layoutManager.getViewLayout 'CardView'

    @initCard()
    @initQuestion()
    @initChoices()
    @initAnswer()
    @initGestures()

  initCard: ->
    @flipRadians = 1

    @flipTransition = new Transitionable(0)
    @state = new Modifier
      origin: @layout.card.origin
      transform: =>
        Transform.rotateY Math.PI * @flipTransition.get()

    # align is dynamically set by parent view
#      align: @layout.card.align
    @mainNode = @add @state
    ## Front Card
    @front = new ImageSurface
      size: @layout.card.size
      content: 'images/Card.svg'
    frontMod = new Modifier
      transform: @layout.card.front.transform
    @mainNode.add(frontMod).add @front
    ## Back Card
    @back = new ImageSurface
      size: @layout.card.size
      content: 'images/Card.svg'
    backMod = new Modifier
      transform: @layout.card.back.transform
    @mainNode.add(backMod).add @back

  initQuestion: ->
    @frontProfilePic = new ImageSurface
      size: @layout.profilePic.size
      classes: @layout.profilePic.big.classes
      properties:
        borderRadius: "#{@layout.profilePic.size[0]}px"
    @frontProfilePicMod = new StateModifier
      origin: @layout.profilePic.big.origin
      align: @layout.profilePic.big.align
      transform: @layout.profilePic.big.transform
    @mainNode.add(@frontProfilePicMod).add @frontProfilePic

    @frontQuestion = new Surface
      size: @layout.question.big.size
      classes: @layout.question.big.classes
    @frontQuestionMod = new StateModifier
      origin: @layout.question.big.origin
      align: @layout.question.big.align
      transform: @layout.question.big.transform
    @mainNode.add(@frontQuestionMod).add @frontQuestion

  initChoices: ->
    @choicesView = new ChoicesView @layout.choices
    @choicesMod = new StateModifier
#   Don't set origin and align, conflicts with parent Modifier
#      origin: @layout.choices.origin
#      align: @layout.choices.align
      transform: @layout.choices.show
    @choicesViewRc = new RenderController
      inTransition: @layout.choices.inTransition
      outTransition: @layout.choices.outTransition
# example usage of inTransformFrom:
#    @choicesViewRc.inTransformFrom (t) ->
#      Transform.translate 0, Utils.getViewportHeight() * t, 0
    @mainNode.add(@choicesMod).add @choicesViewRc
    @choicesViewRc.show @choicesView
    @choiceShowing = true
    @choicesView.on 'choice:win', =>
      @_eventOutput.emit 'win',
        peggeeId: @card.peggeeId
        id: @card.id
        answerId: @card.answer.id
#      Timer.setTimeout @toggleChoices, @layout.card.transition.duration
      @flip()

  initAnswer: ->
    @backImage = new ImageSurface
      size: @layout.answerImage.size
      classes: @layout.answerImage.classes
      properties:
        borderRadius: "#{@layout.answerImage.borderRadius}px"
        maxHeight: "#{@layout.answerImage.maxHeight}px"
#        maxWidth: "#{@layout.answerImage.maxWidth}px"
    @backImage.on 'click', =>
      #TODO Expand image when
#      @toggleZoom()
    @backImageModifier = new StateModifier
      transform: @layout.answerImage.transform
    @mainNode.add(@backImageModifier).add @backImage

    @backText = new Surface
      size: @layout.answerText.size
      classes: @layout.answerText.classes
    @backTextModifier = new StateModifier
      transform: @layout.answerText.transform
    @mainNode.add(@backTextModifier).add @backText

    @addImageButton = new ImageSurface
      size: @layout.addImage.size
      content: @layout.addImage.content
      classes: @layout.addImage.classes
    addImageMod = new StateModifier
#      origin: @layout.addImage.origin
#      align: @layout.addImage.align
      transform: @layout.addImage.transform
    @addImageRenderer = new RenderController
    imagePickView = new ImagePickView()
    @addImageButton.on 'click', =>
      imagePickView.pick( (results) =>
        # console.log JSON.stringify(results)
        @backImage.setContent results.fullS3
        @_eventOutput.emit 'plug',
          id: @card.id
          full: results.fullS3
          thumb: results.thumb.S3
      )
    @addImageRenderer.hide @addImageButton
    @mainNode.add imagePickView
    @mainNode.add(addImageMod).add(@addImageRenderer)

  # Doesn't respond to gestures, just makes sure that the events
  # get to the right place
  initGestures: ->
    @front.pipe @_eventOutput
    @frontProfilePic.pipe @_eventOutput
    @frontQuestion.pipe @_eventOutput
    @back.pipe @_eventOutput
    @backImage.pipe @_eventOutput
    @backText.pipe @_eventOutput
    @choicesView.pipe @_eventOutput

  clearCard: () ->
    # clear content
    @backImage.setContent ""
    @backText.setContent ""
    @choicesView.clearChoices()
    @frontProfilePic.setContent ""
    @frontQuestion.setContent ""
    @addImageRenderer.hide @addImageButton

    # clear event listeners
    @front.removeListener 'click', @toggleChoices
    @frontProfilePic.removeListener 'click', @toggleChoices
    @frontQuestion.removeListener 'click', @toggleChoices
    @choicesView.removeListener 'choice', @pickAnswer

    # reset card elements positioning
    @toggleChoices() if @choiceShowing

  loadCard: (card) ->
    @clearCard()
    @card = card

    if @card.answer?
      @loadAnswer @card.answer.plug, @card.answer.text

    if card.type is 'review'
      @loadAnswer @card.answer.plug, @card.answer.text
      @frontProfilePic.setContent "#{@card.pic}/?height=100&type=normal&width=100"
      if card.peggeeId is UserStore.getUser().id
        @addImageRenderer.show @addImageButton
    else if card.type is 'deny'
      @frontProfilePic.setContent "#{@card.pic}"
      @loadAnswer @card.answer.plug, null
    else
      @front.on 'click', @toggleChoices
      @frontProfilePic.on 'click', @toggleChoices
      @frontQuestion.on 'click', @toggleChoices
      @frontProfilePic.setContent "#{@card.pic}/?height=100&type=normal&width=100"

    if @card.question.length > 90
      @layout.question.classes = ["#{@layout.question.big.classes}--medium"]
    @frontQuestion.setContent @card.question
    if @currentSide is 1
      @flip()
    else
      @currentSide = 0

    @choicesView.load @card
    @choicesView.on 'choice', @pickAnswer

  toggleChoices: =>
    if @choiceShowing
      @frontQuestion.setClasses @layout.question.big.classes
      @frontQuestion.setSize @layout.question.big.size
      Utils.animate(@frontQuestionMod, @layout.question.big)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.big)
      @choicesViewRc.hide(@choicesView)
      @_eventOutput.emit 'choices:hidden', @
      @choiceShowing = false
    else
      @frontQuestion.setClasses @layout.question.small.classes
      @frontQuestion.setSize @layout.question.small.size
      Utils.animate(@frontQuestionMod, @layout.question.small)
      Utils.animate(@frontProfilePicMod, @layout.profilePic.small)
      @choicesViewRc.show(@choicesView)
      @_eventOutput.emit 'choices:showing', @
      @choiceShowing = true


  pickAnswer: (id) =>
    choice = @card.choices[id]
    if @card.answer?
      @front.removeListener 'click', @toggleChoices
      @frontProfilePic.removeListener 'click', @toggleChoices
      @frontQuestion.removeListener 'click', @toggleChoices
#      @choicesViewRc.hide @choicesView
      @_eventOutput.emit 'pegg',
        peggeeId: @card.peggeeId
        id: @card.id
        choiceId: choice.id
        answerId: @card.answer.id
    else
      @_eventOutput.emit 'pref',
        id: @card.id
        choiceId: choice.id
        plug: choice.plug
        thumb: choice.thumb
      @loadAnswer choice.plug, choice.text
      @addImageRenderer.show @addImageButton
#      @choicesViewRc.hide @choicesView
#      Timer.setTimeout @toggleChoices, @layout.card.transition.duration
      @flip()

  flip: =>
    @currentSide = if @currentSide is 1 then 0 else 1
    @flipTransition.set(-@currentSide, @layout.card.transition)
#    @choicesViewRc.hide @choicesView
    # hideShow = if @currentSide is 1 then @layout.card.front.hide else @layout.card.front.show
    # @frontProfilePicMod.setTransform hideShow
    # @frontQuestionMod.setTransform hideShow
    # @choicesMod.setTransform hideShow
    @_eventOutput.emit 'card:flipped', @

  loadAnswer: (image, text) =>
    @backImage.setContent image
    @backText.setContent text

  toggleZoom: =>
    if @big
      @big = false
      @backImage.setSize @layout.answerPic.size
    else
      @big = true
      @backImage.setSize [Utils.getViewportWidth(), Utils.getViewportHeight()]


module.exports = CardView
