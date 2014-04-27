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
    scrollview = new Scrollview
    scrollview.sequenceFrom surfaces
    i = 0

    #debugger
    while i < @questions.models.length
      question = @questions.models[i]
      image = question.get 'link'
      title = question.get 'title'
      temp = new Surface(
        #size: [undefined, 50]
        content: "
          <h2>#{title}</h2>
          <img src='#{image}' />
        "
        classes: ['question']
      )
      temp.pipe scrollview
      surfaces.push temp
      i++

    container.add scrollview
    @add scrollview

###
    @questions.each (question) =>
      #link = question.get 'link'
      #"<img src='#{link}' />"
      surfaces.push new Surface(
        size: [undefined, 50]
        content: question.get 'title'
        classes: ['question']
      ).pipe(scrollview)
###



module.exports = ListQuestionsView
