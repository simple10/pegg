require './scss/card.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'
GenericSync = require 'famous/inputs/GenericSync'
MouseSync = require 'famous/inputs/MouseSync'
TouchSync = require 'famous/inputs/TouchSync'

_ = require('Parse')._
PlayActions = require 'actions/PlayActions'
ImagePickView = require 'views/ImagePickView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'
ChoicesView = require 'views/ChoicesView'
Utils = require 'lib/Utils'

class CardView extends View
  @DEFAULT_OPTIONS:
    width: Utils.getViewportWidth() - Utils.getViewportWidth() * .1
    height: Utils.getViewportHeight() - Utils.getViewportHeight() * .35
    depth: -5
    borderRadius: 10
    transition:
      duration: 300
      easing: Easing.outCubic
    pic:
      width: 100
      height: 100
    question:
      classes: ['card__front__question']


  constructor: (options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @initCard()
    @initQuestion()
    @initChoices()
    @initAnswer()
    @initGestures()

  initCard: ->
    @state = new StateModifier
      origin: [0.5, 0.5]
    @mainNode = @add @state
    ## Front Card
    @front = new ImageSurface
      size: [ @options.width, @options.height ]
      content: 'images/Card_White.png'
    modifier = new Modifier
      transform: Transform.translate 0, 0, @options.depth/2
    @mainNode.add(modifier).add @front
    ## Back Card
    @back = new ImageSurface
      size: [ @options.width, @options.height ]
      content: 'images/Card_White.png'
    modifier = new Modifier
      transform: Transform.multiply(
        Transform.translate(0, 0, -@options.depth/2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(modifier).add @back

    if @options.type is 'review'
      @front.on 'click', @flip
      @back.on 'click', @flip
    else
      @front.on 'click', @toggleChoices
      @back.on 'click', =>
        @_eventOutput.emit 'comment', @

  initQuestion: ->
    @frontProfilePic = new ImageSurface
      size: [@options.pic.width, @options.pic.height]
      #classes: ['card__front__pic--big']
      properties:
        borderRadius: "#{@options.pic.width}px"
    @frontProfilePicMod = new StateModifier
      transform: Transform.translate 0, -110, @options.depth/2 + 2
    @frontQuestion = new Surface
      size: [ @options.width, @options.height ]
      classes: @options.question.classes
    @qModifier = new StateModifier
      transform: Transform.translate 0, @options.height/2 + -40, @options.depth/2 + 2
    @mainNode.add(@qModifier).add @frontQuestion
    @mainNode.add(@frontProfilePicMod).add @frontProfilePic

    if @options.type is 'review'
      @frontProfilePic.on 'click', @flip
      @frontQuestion.on 'click', @flip
    else
      @frontProfilePic.on 'click', @toggleChoices
      @frontQuestion.on 'click', @toggleChoices

  initChoices: ->
    @showChoices = true
    @choicesView = new ChoicesView {width: @options.width, height: @options.height}
    @choicesMod = new StateModifier
    @mainNode.add(@choicesMod).add @choicesView
    @choicesMod.setTransform Transform.translate(0,0,-10)

  initAnswer: ->
    @backImage = new ImageSurface
      size: [@options.width - 40, null]
      classes: ['card__back__image']
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{@options.height - 100}px"
    
    @backImage.on 'click', =>
      #TODO Expand image when

    @backImageModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -100, -@options.depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @backText = new Surface
      size: [@options.width - 40, null]
      classes: ['card__back__text']
    @backTextModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -160, -@options.depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(@backImageModifier).add @backImage
    @mainNode.add(@backTextModifier).add @backText

    if @options.type isnt 'review'
      addImageButton = new ImageSurface
        size: [43, 48]
        classes: ['card__back__image']
        content: 'images/add-image.png'
      @addImageModifier = new StateModifier
        transform: Transform.multiply(
          Transform.translate(0, 150, -@options.depth/2 - 2)
          Transform.multiply(
              Transform.rotateZ Math.PI
              Transform.rotateX Math.PI
          )
        )
      imagePickView = new ImagePickView()
      addImageButton.on 'click', =>
        imagePickView.pick( (results) =>
          console.log JSON.stringify(results)
          @backImage.setContent results[0].url
          PlayActions.plug @id, results[0].url
        )
      @mainNode.add imagePickView
      @mainNode.add(@addImageModifier).add addImageButton

  # Doesn't respond to gestures, just makes sure that the events
  # get to the right place
  initGestures: ->
    @front.pipe @_eventOutput
    @frontProfilePic.pipe @_eventOutput
    @frontQuestion.pipe @_eventOutput
    @back.pipe @_eventOutput
    @backImage.pipe @_eventOutput
    @backText.pipe @_eventOutput

  loadCard: (id, card) ->
    @card = card
    @id = id
    if @card.question.length > 90
      @options.question.classes = ["#{@options.question.classes}--medium"]
    @frontQuestion.setContent @card.question
    @frontProfilePic.setContent "#{@card.pic}/?height=200&type=normal&width=200"
    if @options.type is 'review'
      @loadAnswer @card.plug, @card.answer.get 'text'

  loadChoices: (cardId) ->
    @choicesView.load cardId
    @choicesView.on 'choice', ((i) ->
      @pickAnswer i
    ).bind @

  toggleZoom: =>
    if @big
      @big = false
      @backImage.setSize [@options.width, @options.height]
    else
      @big = true
      @backImage.setSize [Utils.getViewportWidth(), Utils.getViewportHeight()]

  toggleChoices: =>
    if @showChoices
      @frontQuestion.setClasses ["#{@options.question.classes}--small"]
      @frontQuestion.setSize [@options.width - 80, @options.height]
      @qModifier.setTransform(
        Transform.translate 30, 20, @options.depth/2 + 2
        @options.transition
      )
      @frontProfilePicMod.setTransform(
        Transform.multiply(
          Transform.scale .5, .5, 1
          Transform.translate -210, -260, @options.depth/2 + 2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 50, 0
      @choicesView.showChoices()
      @showChoices = false
      @_eventOutput.emit 'choices:showing', @
    else
      console.log 'toggleChoices'
      @frontQuestion.setClasses @options.question.classes
      @frontQuestion.setSize [@options.width, @options.height]
      @qModifier.setTransform(
        Transform.translate 0, @options.height/2 + -40, @options.depth/2 + 2
        @options.transition
      )
      @frontProfilePicMod.setTransform(
        Transform.multiply(
          Transform.scale 1, 1, 1
          Transform.translate 0, -110, @options.depth/2 + 2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 0, -10
      @choicesView.hideChoices()
      @showChoices = true
      @_eventOutput.emit 'choices:hidden', @

  pickAnswer: (i) =>
    choice = @card.choices[i]
    if @card.peggee?
      PlayActions.pegg @card.peggee, @id, choice.id, @card.answer.id
      if @card.answer.id is choice.id
        @choiceWin choice, i
      else
        @choiceFail choice, i
      @addImageModifier.setTransform Transform.translate 0,0, -1000
    else
      PlayActions.pref @id, choice.id, choice.image
      @loadAnswer choice.image, choice.text
      @flip choice

  choiceFail: (choice, i) =>
    @choicesView.fail choice, i

  choiceWin: (choice, i) =>
    @choicesView.win choice, i
    @choicesView.on 'choice:doneShowingStatus', () =>
      @loadAnswer @card.plug, choice.text
      @flip()

  flip: =>
    @currentSide = if @currentSide is 1 then 0 else 1
    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      @options.transition
    )
    @_eventOutput.emit 'card:flipped', @

  loadAnswer: (image, text) =>
    @backImage.setContent image
    @backText.setContent text

module.exports = CardView
