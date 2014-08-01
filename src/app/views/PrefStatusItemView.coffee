
require './scss/status.scss'

View = require 'famous/core/View'
Surface = require 'famous/core/Surface'
ImageSurface = require 'famous/surfaces/ImageSurface'
StateModifier = require 'famous/modifiers/StateModifier'
Transform = require 'famous/core/Transform'
ContainerSurface = require 'famous/surfaces/ContainerSurface'

class PrefStatusItemView extends View

  container = null

  constructor: (options) ->
    super options
    @_choices = []
    @_percentages = []
    @_question = ''
    @_total = 0
    @init()

  init: ->
    container = new ContainerSurface
      size: [window.innerWidth, 350]
      properties:
        overflow: 'hidden'

    # Question
    @_question = new Surface
      classes: ['status__pref__question']
      size: [window.innerWidth-40, 80]
    questionMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 20, null, null
    container.add(questionMod).add @_question
    container.pipe @._eventOutput

    i=0
    while i < 4
      @_addChoice(i)
      i++

    @add container

  _addChoice: (i) ->
    choice = new Surface
      classes: ['status__pref__choice']
      size: [window.innerWidth-60, 50]
    choiceMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, 60 * i + 60, null
    container.add(choiceMod).add choice
    @_choices.push choice

    switch i
      when 0
        classes = ['status__pref__percentage--red']
      when 1
        classes = ['status__pref__percentage--yellow']
      when 2
        classes = ['status__pref__percentage--green']
      when 3
        classes = ['status__pref__percentage--blue']

    percentage = new Surface
      classes: classes
      size: [3, 10]
    percentageMod = new StateModifier
      align: [0, 0]
      origin: [0, 0]
      transform: Transform.translate 30, 60 * i + 50, null
    container.add(percentageMod).add percentage
    percentage.pipe @._eventOutput
    @_percentages.push percentage

  load: (data) =>
    @_question.setContent data.question
    @_total = data.total

    console.log data
    i = 0
    for id, choice of data.choices
      @_choices[i].setContent choice.choiceText
      @_percentages[i].setSize [ (window.innerWidth-60) * (choice.count / @_total) + 3, 10 ]
      if i is 3 then break
      i++



module.exports = PrefStatusItemView
