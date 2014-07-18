require './scss/card.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Utility = require 'famous/utilities/Utility'
Easing = require 'famous/transitions/Easing'
PlayActions = require 'actions/PlayActions'
Timer = require 'famous/utilities/Timer'
ChoicesView = require 'views/ChoicesView'
_ = require('Parse')._
ImageUploadView = require 'views/ImageUploadView'
PlayStore = require 'stores/PlayStore'
Constants = require 'constants/PeggConstants'

class CardView extends View
  @DEFAULT_OPTIONS:
    width: window.innerWidth - window.innerWidth * .1
    height: window.innerHeight - window.innerHeight * .38
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


  constructor: (id, card, options) ->
    options = _.defaults options, @constructor.DEFAULT_OPTIONS
    super options
    @card = card
    @id = id
    width = @options.width
    height = @options.height
    depth = @options.depth
    @initCard width, height, depth
    @initQuestion width, height, depth
    @initChoices width, Math.floor(height/5)
    @initAnswer width, height, depth

  initCard: (width, height, depth) ->
    if @card.question.length > 90
      @options.question.classes = ["#{@options.question.classes}--medium"]
    @state = new StateModifier
      origin: [0.5, 0.5]
    @mainNode = @add @state
    ## Front Card
    front = new ImageSurface
      size: [ width, height ]
      content: 'images/Card_White.png'
    modifier = new Modifier
      transform: Transform.translate 0, 0, depth/2
    front.on 'click', @toggleChoices
    @mainNode.add(modifier).add front
    ## Back Card
    @back = new ImageSurface
      size: [ width, height ]
      content: 'images/Card_White.png'
    modifier = new Modifier
      transform: Transform.multiply(
        Transform.translate(0, 0, -depth/2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(modifier).add @back
    @back.on 'click', =>
      @_eventOutput.emit 'comment', @

  initQuestion: (width, height, depth) ->
    @pic = new ImageSurface
      size: [@options.pic.width, @options.pic.height]
      content: "#{@card.pic}/?height=200&type=normal&width=200"
      #classes: ['card__front__pic--big']
      properties:
        borderRadius: "#{@options.pic.width}px"
    @pic.on 'click', @toggleChoices
    @picMod = new StateModifier
      transform: Transform.translate 0, -110, depth/2 + 2
    if @card.peggee?
      question = @card.firstName + ", " + @card.question.charAt(0).toLowerCase() + @card.question.slice(1)
    else
      question = @card.question
    @question = new Surface
      size: [ width, height ]
      classes: @options.question.classes
      content: question
    @qModifier = new StateModifier
      transform: Transform.translate 0, height/2 + -40, depth/2 + 2
    @question.on 'click', @toggleChoices
    @mainNode.add(@qModifier).add @question
    @mainNode.add(@picMod).add @pic

  initChoices: (width, height) ->
    @showChoices = true
    @choicesView = new ChoicesView {width: width, height: 50}
    @choicesMod = new StateModifier
    @mainNode.add(@choicesMod).add @choicesView
    @choicesMod.setTransform Transform.translate(0,0,-10)

  initAnswer: (width, height, depth) ->
    @image = new ImageSurface
      size: [width - 40, null]
      classes: ['card__back__image']
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{height - 100}px"
    @image.on 'click', =>
      @flip()
    @imageModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -100, -depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @text = new Surface
      size: [width - 40, null]
      classes: ['card__back__text']
    @textModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -160, -depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(@imageModifier).add @image
    @mainNode.add(@textModifier).add @text

  loadChoices: (cardId) ->
    @choicesView.load cardId
    @choicesView.on 'choice', ((i) ->
      @pickAnswer i
    ).bind @


  toggleZoom: =>
    if @big
      @big = false
      @image.setSize [@options.width, @options.height]
    else
      @big = true
      @image.setSize [window.innerWidth, window.innerHeight]

  toggleChoices: =>
    if @showChoices
      @question.setClasses ["#{@options.question.classes}--small"]
      @question.setSize [@options.width - 80, @options.height]
      @qModifier.setTransform(
        Transform.translate 30, 20, @options.depth/2 + 2
        @options.transition
      )
      @picMod.setTransform(
        Transform.multiply(
          Transform.scale .5, .5, 1
          Transform.translate -210, -260, @options.depth/2 + 2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 50, 0
      @showChoices = false
    else
      @question.setClasses @options.question.classes
      @question.setSize [@options.width, @options.height]
      @qModifier.setTransform(
        Transform.translate 0, @options.height/2 + -40, @options.depth/2 + 2
        @options.transition
      )
      @picMod.setTransform(
        Transform.multiply(
          Transform.scale 1, 1, 1
          Transform.translate 0, -110, @options.depth/2 + 2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 0, -10
      @showChoices = true

  pickAnswer: (i) =>
    choice = @card.choices[i]
    if @card.peggee?
      PlayActions.pegg @card.peggee, @id, choice.id, @card.answer.id
      if @card.answer.id is choice.id
        @choiceWin choice
      else
        @choiceFail choice
    else
      PlayActions.pref @id, choice.id
      @flip choice

  choiceFail: (choice) =>
    @choicesView.fail choice

  choiceWin: (choice) =>
    @choicesView.win choice
    Timer.after ( =>
      @flip choice
    ), 10

  flip: (choice) =>
    if choice?
      image = choice.image
      text = choice.text
      Timer.after ( =>
        @image.setContent image
      ), 10
      @text.setContent text
    @currentSide = if @currentSide is 1 then 0 else 1
    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      @options.transition
    )


module.exports = CardView
