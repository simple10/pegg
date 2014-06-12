# NewCardView1
#
# Enter question and continue

require './scss/newcard.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'


class NewCardView extends View
  cssPrefix: 'newcard'

  @DEFAULT_OPTIONS:
    input:
      width: window.innerWidth - 50
      height: 40

  constructor: ->
    super
    @init()

  init: ->
    cardIcon = new ImageSurface
      size: [83, 58]
      classes: ['newcard_card_icon']
      content: "images/newcard_medium2.png"
    cardIconMod = new StateModifier
      origin: [0.35, 0.5]
      align: [0.5, 0.15]
    @add(cardIconMod).add cardIcon
    @newCardTitle = new Surface
      size: [@options.input.width, 50]
      content: 'NEW CARD'
      classes: ['newcard__header']
    newCardMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.28]
    @add(newCardMod).add @newCardTitle
    @step1()

  step1: ->
    @step1Mods = []
    @addNum(1)
    @addSurface(1,
      size: [@options.input.width, @options.input.height]
      content: '<input type="text" name="question" placeholder="Write a question" id="question"/>'
      classes: ["#{@cssPrefix}__question--input"]
    )
    @addButton(1,
      content: "Continue"
      classes: ['newcard__button']
    , =>
      @hideStep(@step1Mods)
      @step2()
    )
    @showStep(190, @step1Mods)

  step2: ->
    @step2Mods = []
    @addNum(2)
    for i in [1..4]
      @addSurface(2,
        size: [@options.input.width, @options.input.height]
        content: "<input type='text' name='answer' placeholder='Answer option #{i}' id='answer#{i}'/>"
        classes: ["#{@cssPrefix}__answer--input"]
      )
    @addButton(2,
      content: "Continue"
      classes: ['newcard__button']
    , =>
      @hideStep(@step2Mods)
      @step3()
    )
    Timer.after (=>
      @showStep(190, @step2Mods)
    ), 20

  step3: ->
    @step3Mods = []
    @addNum(3)
    @addLinkContainer(3,
      size: [59, 60]
      image: 'images/deck_existing.png'
      text: 'Place card in existing deck(s)'
      classes: {image: ['newcard__step3__deckIcon'], text: ['newcard__step3__deckText']}
    , =>
        alert "existing deck"
    )
    @addLinkContainer(3,
      size: [73, 59]
      image: 'images/deck_new.png'
      text: 'Create a new deck'
      classes: {image: ['newcard__step3__deckIcon'], text: ['newcard__step3__deckText']}
    , =>
      alert "new deck"
    )
    @addButton(3,
      content: "Finish"
      classes: ['newcard__button']
    , =>
      @hideStep(@step3Mods)
      #TODO: CardStore.create
      @step4()
    )
    Timer.after (=>
      @showStep(190, @step3Mods)
    ), 20

  step4: ->
    @step4Mods = []
    @newCardTitle.setContent "CARD CREATED"
    @addSurface(4,
      size: [@options.input.width, 50]
      content: 'GREAT!'
      classes: ['newcard__header--big']
    )
    @addButton(4,
      content: "Play this card"
      classes: ['newcard__button', 'newcard__button--blue']
    , =>
      @hideStep(@step4Mods)
      #TODO: play card
    )
    @addButton(4,
      content: "Create another card"
      classes: ['newcard__button--blue', 'newcard__button']
    , =>
      @hideStep(@step4Mods)
      #TODO: reset all fields to empty
      @step1()
    )
    Timer.after (=>
      @showStep(240, @step4Mods)
    ), 20

  showStep: (yOffset, steps) ->
    i = 0
    j = steps.length
    while i < steps.length
      Timer.setTimeout ((i) ->
        steps[i].setTransform(
          #Transform.thenMove(Transform.rotateX(1), [0, 100*i, -0])
          Transform.translate(0, yOffset + 60*i, 0)
          duration: 600
          curve: Easing.outCubic
        )
      ).bind(@, i), j * 100
      i++
      j--

  hideStep: (steps) ->
    i = 0
    j = steps.length
    while i < steps.length
      Timer.setTimeout ((i) ->
        steps[i].setTransform(
          Transform.thenMove(Transform.rotateZ(1), [0, window.innerHeight*2, -300])
          duration: 600
          curve: Easing.inCubic
        )
      ).bind(@, i), j * 100
      i++
      j--

  addSurface: (step, options)->
    surface = new Surface
      size: options.size
      content: options.content
      classes: options.classes
    surfaceMod = new StateModifier
      origin: [0.5, 1]
      align: [0.5, 0]
    @["step#{step}Mods"].push surfaceMod
    @add(surfaceMod).add surface

  addNum: (step)->
    num = new Surface
      size: [30, 30]
      content: step
      classes: ['newcard__number']
    numMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.05]
    @["step#{step}Mods"].push numMod
    @add(numMod).add num

  addButton: (step, params, func)->
    submit = new Surface
      size: [@options.input.width, @options.input.height]
      content: params.content
      classes: params.classes
      properties:
        lineHeight: @options.input.height + "px"
    submitMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.05]
    @["step#{step}Mods"].push submitMod
    @add(submitMod).add submit
    submit.on 'click', func

  addLinkContainer: (step, options, func) ->
    image = new ImageSurface
      size: options.size
      classes: options.classes.image
      content: options.image
    imageMod = new StateModifier
      origin: [0, 0.5]
      align: [0, 0.5]
    text = new Surface
      size: [@options.input.width - 59, 60]
      content: options.text
      classes: options.classes.text
      properties:
        lineHeight: "#{options.size[0]}px"
    textMod = new StateModifier
      origin: [0, 0.5]
      align: [0.3, 0.5]
    container = new ContainerSurface
      size: [@options.input.width, options.size[1]]
    container.add(imageMod).add image
    container.add(textMod).add text
    containerMod = new StateModifier
      origin: [0.5, 1]
      align: [0.5, 0]
    @["step#{step}Mods"].push containerMod
    @add(containerMod).add container
    container.on "click", func


module.exports = NewCardView
