
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
SequentialLayout = require 'famous/views/SequentialLayout'
RenderNode = require 'famous/core/RenderNode'

class PrefStatusItemView extends View
  @DEFAULT_OPTIONS:
    size: [undefined, window.innerHeight]

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
      size: [window.innerWidth, 400]
      properties:
        overflow: 'hidden'
    container.pipe @._eventOutput

    sequentialLayout = new SequentialLayout
    sequentialLayout.sequenceFrom @_sequence

    # QUESTION
    questionNode = new RenderNode
    @_question = new Surface
      classes: ['status__pref__question']
      size: [window.innerWidth-40, 80]
    questionMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 20, null, null
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
    percentage = new Surface
      classes: classes
      size: [3, 10]
    percentageMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    percentageNode.add(percentageMod).add percentage
    @_sequence.push percentageNode
    @_percentages.push percentage

    # CHOICE TEXT
    choiceNode = new RenderNode
    choice = new Surface
      classes: ['status__pref__choice']
      size: [window.innerWidth-60, 60]
    choiceMod = new StateModifier
      align: [0, 0.02]
      origin: [0, 0]
      transform: Transform.translate 30, null, null
    choiceNode.add(choiceMod).add choice
    @_sequence.push choiceNode
    @_choices.push choice

  load: (data) =>
    @_question.setContent data.question
    @_total = data.total

    console.log data
    i = 0
    for id, choice of data.choices
      @_choices[i].setContent choice.choiceText
      @_percentages[i].setSize [ (window.innerWidth-60) * (choice.count / @_total) + 3, 10 ]
      @_question.setSize [window.innerWidth-40, 80 + Math.floor(data.question.length/25) * 10]
      if i is 3 then break
      i++

    # TODO: remove empty choices from sequence



module.exports = PrefStatusItemView
