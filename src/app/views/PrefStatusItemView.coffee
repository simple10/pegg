
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'
RenderNode = require 'famous/core/RenderNode'
Utils = require 'lib/Utils'

class PrefStatusItemView extends View
  @DEFAULT_OPTIONS:
    size: [undefined, Utils.getViewportHeight()]

  constructor: (options) ->
    super options
    @_sequence = []
    @_choices = []
    @_percentages = []
    @_question = ''
    @_total = 0
    @_init()

  _init: ->
    container = new ContainerSurface
      size: [Utils.getViewportWidth(), undefined]
      # properties:
      #   overflow: 'hidden'
    container.pipe @._eventOutput

    sequentialLayout = new SequentialLayout
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
    sequentialLayout.sequenceFrom @_sequence

    # QUESTION
    questionNode = new RenderNode
#    cardSurface = new ImageSurface
#      size: [Utils.getContentWidth(), 380]
#      content: 'images/Card.svg'
#      classes: ['status__pref__card']
#    cardSurfaceMod = new StateModifier
#      align: [0, 0]
#      origin: [0, 0]
#      transform: Transform.translate 15, -10, null
#    questionNode.add(cardSurfaceMod).add cardSurface

    @_question = new Surface
      classes: ['status__pref__question']
      # size: [Utils.getContentWidth()-20, 140]
    questionMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    questionNode.add(questionMod).add @_question

    @_sequence.push questionNode

    # CHOICES
    i=0
    while i < 4
      @_addChoice(i)
      i++
    container.add sequentialLayout
    @add container


  _addChoice: (i) ->
    # CHOICE LINE BAR
    switch i
      when 0
        classes = ['status__pref__percentage--red']
      when 1
        classes = ['status__pref__percentage--yellow']
      when 2
        classes = ['status__pref__percentage--green']
      when 3
        classes = ['status__pref__percentage--blue']
    percentageNode = new RenderNode
    percentageBar = new Surface
      classes: classes
      size: [3, 40]
    percentageText = new Surface
      classes: ['status__pref__percentage']
      size: [null, 40]
      content: '???%'
    percentageBarMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    percentageTextMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    percentageNode.add(percentageBarMod).add percentageBar
    percentageNode.add(percentageTextMod).add percentageText
    @_sequence.push percentageNode
    @_percentages.push
      bar: percentageBar
      barMod: percentageBarMod
      text: percentageText
      textMod: percentageTextMod

    # CHOICE TEXT
    choiceNode = new RenderNode
    choice = new Surface
      classes: ['status__pref__choice']
      size: [Utils.getViewportWidth()-60, 60]
    choiceMod = new StateModifier
      align: [0, 0.02]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    choiceNode.add(choiceMod).add choice
    @_sequence.push choiceNode
    @_choices.push choice

  load: (data) =>
    @_question.setContent "
      <div class='status__pref__question__parent'>
          <div class='status__pref__question__child'>
          #{data.question}
          </div>
      </div>​​​​​​​​​​​​​​​​​​​​​​​​"
    @_total = data.total

    console.log data
    i = 0
    for id, choice of data.choices
      @_choices[i].setContent choice.choiceText
      fraction = choice.count / @_total
      width = (Utils.getViewportWidth()-60) * fraction + 3
      @_percentages[i].bar.setSize [ width, 40 ]
      @_percentages[i].text.setContent "#{Math.round fraction * 100}%"
      if fraction < 0.25
        @_percentages[i].textMod.setTransform Transform.translate width + 30, null, null
      @_question.setSize [Utils.getViewportWidth()-40, 60 + Math.floor(data.question.length/25) * 10]
      if i is 3 then break
      i++

    # TODO: remove empty choices from sequence



module.exports = PrefStatusItemView
