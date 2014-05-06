require 'styles/views/questions'

View = require 'famous/core/View'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
GridLayout = require 'famous/views/GridLayout'

class QuestionView extends View

  constructor: (collection, options) ->
    super options
    @question = collection.models[Math.floor(Math.random() * 38) + 1]
    @build()

  build: ->

    #debugger
    title = @question.get 'title'
    image1 =  @question.get 'image1'

    #<img src='#{image1}'/>

    grid = new GridLayout
      dimensions: [2, 2]

    answers = []
    grid.sequenceFrom(answers);

    question = new Surface
      size: [undefined, 50]
      content: "<h2>#{title}</h2>"
      classes: ['question']

    @add question

    answerBox = new ContainerSurface
      size: [500, 500]

    answer1 = new Surface
      size: [undefined, undefined]
      content: @question.get 'caption1'
      classes: ['answer']

    #stateModifier.add answer1

    answer1.on 'click', ->
      alert('answer1')

    answer2 = new Surface
      size: [undefined, undefined]
      content: @question.get 'caption2'
      classes: ['answer']

    answer2.on 'click', =>
      alert('answer2')

    answer3 = new Surface
      size: [undefined, undefined]
      content: @question.get 'caption3'
      classes: ['answer']

    answer3.on 'click', =>
      alert('answer3')

    answer4 = new Surface
      size: [undefined, undefined]
      content:  @question.get 'caption4'
      classes: ['answer']

    answer4.on 'click', =>
      alert('answer4')

    answers.push answer1
    answers.push answer2
    answers.push answer3
    answers.push answer4


    answerBox.add grid

    @add new Modifier
      origin: [.5, .5]
    .add answerBox




module.exports = QuestionView
