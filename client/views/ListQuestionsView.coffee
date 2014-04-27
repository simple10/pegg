require 'styles/views/questions'

View = require 'famous/core/View'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'

class ListQuestionsView extends View

  constructor: (collection, options) ->
    super options
    @questions = collection
    @build()

  build: ->
    container = new ContainerSurface(
      size: [400, undefined]
      properties:
        overflow: "hidden"
    )

    surfaces = []
    @questions.each (question) ->
      surfaces.push new Surface
        size: [undefined, 50]
        content: question.get('question')
        classes: ['question']

    scrollview = new Scrollview
    scrollview.sequenceFrom surfaces
    container.add scrollview

    @add scrollview

module.exports = ListQuestionsView
