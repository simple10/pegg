# NewCardView1
#
# Enter question and continue

require './scss/newcard.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
Modifier = require 'famous/core/Modifier'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
Easing = require 'famous/transitions/Easing'
Timer = require 'famous/utilities/Timer'


class NewCardView extends View
  cssPrefix: 'newcard'

  @DEFAULT_OPTIONS:
    input:
      width: window.innerWidth
      height: 40

  constructor: ->
    super
    @init()
    @step1()

  init: ->
    cardIcon = new ImageSurface
      size: [83, 58]
      classes: ['newcard_card_icon']
      content: "images/newcard_medium2.png"
    cardIconMod = new StateModifier
      origin: [0.35, 0.5]
      align: [0.5, 0.15]
    @add(cardIconMod).add cardIcon
    newCard = new Surface
      size: [@options.input.width, 50]
      content: 'NEW CARD'
      classes: ['newcard__header']
    newCardMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, 0.28]
    @add(newCardMod).add newCard

  step1: ->
    @step1Mods = []
    @addNum(1)
    question = new Surface
      size: [@options.input.width-50, @options.input.height]
      content: '<input type="text" name="question" placeholder="Write a question"/>'
      classes: ["#{@cssPrefix}__question--input"]
    questionMod = new StateModifier
      origin: [0.5, 1]
      align: [0.5, 0]
    @step1Mods.push questionMod
    @add(questionMod).add question
    @addButton(1, =>
      @hideSteps(@step1Mods)
      @step2()
    )
    @showSteps(@step1Mods)


  step2: ->
    @step2Mods = []
    @addNum(2)
    for i in [1..4]
      answer = new Surface
        size: [@options.input.width-50, @options.input.height]
        classes: ['card__front__option']
        content: "<input type='text' name='question' placeholder='Answer option #{i}'/>"
        classes: ["#{@cssPrefix}__question--input"]
      answerMod = new StateModifier
        origin: [0.5, 1]
        align: [0.5, 0]
        opacity: 0
        transform: Transform.translate 0, 0, -5
      @step2Mods.push answerMod
      @add(answerMod).add answer
    @addButton(2, =>
      @hideSteps(@step2Mods)
      #@step3()
    )
    Timer.after (=>
      @showSteps(@step2Mods)
    ), 20

  showSteps: (steps) ->
    i = 0
    j = steps.length
    while i < steps.length
      Timer.setTimeout ((i) ->
        steps[i].setOpacity 1
        steps[i].setTransform(
          #Transform.thenMove(Transform.rotateX(1), [0, 100*i, -0])
          Transform.translate(0, 190 + 60*i, 0)
          duration: 600
          curve: Easing.outCubic
        )
      ).bind(@, i), j * 100
      i++
      j--

  hideSteps: (steps) ->
    i = 0
    j = steps.length
    while i < steps.length
      Timer.setTimeout ((i) ->
        steps[i].setTransform(
          Transform.thenMove(Transform.rotateZ(1), [0, window.innerHeight*2, -300])
          { duration: 600, curve: Easing.inCubic }
        )
      ).bind(@, i), j * 100
      i++
      j--

  addNum: (i)->
    num = new Surface
      size: [30, 30]
      content: i
      classes: ['newcard__number']
    numMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.05]
    @["step#{i}Mods"].push numMod
    @add(numMod).add num

  addButton: (i, func)->
    submit = new Surface
      size: [@options.input.width-50, @options.input.height]
      content: 'Continue'
      classes: ['newcard__question_submit']
      properties:
        lineHeight: @options.input.height + "px"
    submitMod = new StateModifier
      origin: [0.5, 0.5]
      align: [0.5, -0.04]
    @["step#{i}Mods"].push submitMod
    @add(submitMod).add submit
    submit.on 'click', func

module.exports = NewCardView
