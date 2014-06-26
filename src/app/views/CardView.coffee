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
      width: 80
      height: 80


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
    @initChoices width, Math.floor(height/6)
    @initAnswer width, height, depth

  initCard: (width, height, depth) ->
    @state = new StateModifier
    @mainNode = @add @state
    ## Front Card
    front = new ImageSurface
      size: [ width, height ]
      content: "images/Card_White.png"
    modifier = new Modifier
      transform: Transform.translate 0, 0, depth/2
    front.on 'click', @showChoices
    @mainNode.add(modifier).add front
    ## Back Card
    back = new ImageSurface
      size: [ width, height ]
      content: "images/Card_Blue.png"
    modifier = new Modifier
      transform: Transform.multiply(
        Transform.translate(0, 0, -depth/2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(modifier).add back

  initQuestion: (width, height, depth) ->
    @pic = new ImageSurface
      size: [@options.pic.width, @options.pic.height]
      content: @card.pic
      #classes: ['card__front__pic--big']
      properties:
        borderRadius: "#{@options.pic.width}px"
    @picMod = new StateModifier
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      transform: Transform.translate 0, -100, depth/2 + 2
    @question = new Surface
      size: [ width, height ]
      classes: ['card__front__question']
      content: @card.question
    @qModifier = new StateModifier
      transform: Transform.translate 0, height/2 + -60, depth/2 + 2
    @question.on 'click', @toggleChoices
    @mainNode.add(@qModifier).add @question
    @mainNode.add(@picMod).add @pic

  initChoices: (width, height) ->
    @showChoices = true
    @choices = []
    for i in [0..@card.choices.length-1]
      choiceText = @card.choices[i].text
      if choiceText
        choice = new Surface
          size: [ width, height ]
          classes: ['card__front__option']
          content: "
                <div class='outerContainer' style='width: #{width-40}px; height: #{height}px'>
                  <div class='innerContainer'>
                   #{choiceText}
                  </div>
                </div>"
        choice.on 'click', ((i) ->
          @pickAnswer i
        ).bind @, i
        @choices.push choice

    choices = new ChoicesView
    choices.load @choices
    @choicesMod = new StateModifier
    @mainNode.add(@choicesMod).add choices
    @choicesMod.setTransform Transform.translate(0,0,-10)

  initAnswer: (width, height, depth) ->
    @image = new ImageSurface
      size: [width - 40, null]
      classes: ['card__back__image']
      properties:
        borderRadius: "#{@options.borderRadius}px"
        maxHeight: "#{height - 100}px"
    @image.on "click", =>
      PlayActions.rate 0
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
      #content: @card.get('caption1')
    @textModifier = new StateModifier
      transform: Transform.multiply(
        Transform.translate(0, -150, -depth/2 - 2)
        Transform.multiply(
          Transform.rotateZ Math.PI
          Transform.rotateX Math.PI
        )
      )
    @mainNode.add(@imageModifier).add @image
    @mainNode.add(@textModifier).add @text


  toggleImage: =>
    if @big
      @big = false
      @image.setSize [@options.width, @options.height]
    else
      @big = true
      @image.setSize [window.innerWidth, window.innerHeight]

  toggleChoices: =>
    if @showChoices
      #PlayActions.pick @id
      @question.setClasses(['card__front__question--small'])
      @question.setSize [@options.width - 50, @options.height]
      @qModifier.setTransform(
        Transform.translate 30, 20, @options.depth/2 + 2
        @options.transition
      )
      #@pic.setClasses(['card__front__pic--small'])
      @picMod.setTransform(
        Transform.multiply(
          Transform.scale .7, .7, 1
          Transform.translate -150, -185, @options.depth/2 + 2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 30, 0
      @showChoices = false
    else
      @question.setClasses(['card__front__question'])
      @qModifier.setTransform(
        Transform.translate 0, @options.height/2 + -60, @options.depth/2 + 2
        @options.transition
      )
      @picMod.setTransform(
        Transform.multiply(
          Transform.scale 1, 1, 1
          Transform.translate 0, -100, @options.depth/2
        ), @options.transition
      )
      @choicesMod.setTransform Transform.translate 0, 0, -10
      @showChoices = true

  pickAnswer: (choice) =>
    PlayActions.answer @id, @card.choices[choice].id
    Timer.after ( =>
      @image.setContent @card.choices[choice].image
    ), 20
    @text.setContent @card.choices[choice].text
    @flip()

  flip: (side) =>
    @state.halt()
    @currentSide ?= 0
    if side is 0 or side is 1
      @currentSide = side
    else
      @currentSide = if @currentSide is 1 then 0 else 1

    @picMod.setOpacity 0

    @state.setTransform(
      Transform.rotateY Math.PI * @currentSide
      @options.transition
    )


module.exports = CardView
