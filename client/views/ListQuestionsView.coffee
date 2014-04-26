View = require 'famous/core/View'
Modifier  = require 'famous/core/Modifier'
Transform = require 'famous/core/Transform'
Surface = require 'famous/core/Surface'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'

class ListQuestionsView extends View

  constructor: (model, options) ->
    super options
    @model = model
    @build()

  build: ->

    questions = @model.get('questions').models

    container = new ContainerSurface(
      size: [400, undefined]
      properties:
        overflow: "hidden"
    )

    surfaces = []
    scrollview = new Scrollview()
    i = 0

    while i < questions.length
      temp = new Surface(
        size: [undefined, 50]
        content: questions[i].get('question')
        classes: ["red-bg"]
        properties:
          textAlign: "center"
          lineHeight: "50px"
      )
      temp.pipe scrollview
      surfaces.push temp
      i++
    scrollview.sequenceFrom surfaces
    container.add scrollview

    @add scrollview

module.exports = ListQuestionsView