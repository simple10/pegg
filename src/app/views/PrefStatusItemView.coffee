
require './scss/status.scss'

View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
SequentialLayout = require 'famous/src/views/SequentialLayout'
RenderNode = require 'famous/src/core/RenderNode'
Utils = require 'lib/Utils'

class PrefStatusItemView extends View

  constructor: (options) ->
    super options
    @_sequence = []
    @_choices = []
    @_percentages = []
    @_question = ''
    @_total = 0
    @_init()

  _init: ->
    sequentialLayout = new SequentialLayout
      align: [0.5, 0.5]
      origin: [0.5, 0.5]
      itemSpacing: 10
    sequentialLayout.sequenceFrom @_sequence
#    sequentialLayout.pipe @._eventOutput

    # QUESTION
    questionNode = new RenderNode
      size: [Utils.getViewportWidth()-60, 40]
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
      size: [Utils.getContentWidth()-40, true]
    @_question.pipe @._eventOutput
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

    @add sequentialLayout


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
    renderNodeMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      size: [undefined, 30]
    percentageNode = new RenderNode renderNodeMod
    percentageBar = new Surface
      classes: classes
    percentageBar.pipe @._eventOutput
    percentageText = new Surface
      classes: ['status__pref__percentage']
      content: '0%'
    percentageText.pipe @._eventOutput
    percentageBarMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      size: [3, 30]
      transform: Transform.translate 30, null, null
    percentageTextMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      size: [null, 30]
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
      size: [Utils.getViewportWidth()-60, 30]
    choice = new Surface
      classes: ['status__pref__choice']
      size: [Utils.getViewportWidth()-60, true]
    choiceMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    choice.pipe @._eventOutput
    choiceNode.add(choiceMod).add choice
    @_sequence.push choiceNode
    @_choices.push choice

  load: (data) =>
    @_question.setContent data.question
    @_total = data.total
    if !@_total?
      @_total = 1

    console.log data
    i = 0
    for own id, choice of data.choices
      if !choice.count?
        choice.count = 0

      @_choices[i].setContent choice.text
      @_choices[i].setSize [Utils.getViewportWidth()-60, true]
      fraction = choice.count / @_total
      fraction = 0 unless isFinite fraction
      width = (Utils.getViewportWidth()-60) * fraction + 3
      @_percentages[i].bar.setSize [ width, 30 ]
      # TODO: wrap any output of numbers in a helper util to prevent unwanted NaN, Infinity, etc. output
      @_percentages[i].text.setContent "#{Math.round fraction * 100}%"
      if fraction < 0.25
        @_percentages[i].textMod.setTransform Transform.translate width + 30, null, null
      @_question.setSize [Utils.getContentWidth()-40, true]
      if i is 3 then break
      i++

    # TODO: remove empty choices from sequence



module.exports = PrefStatusItemView
