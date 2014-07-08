require './scss/card.scss'

View = require 'famous/core/View'
ContainerSurface = require 'famous/surfaces/ContainerSurface'
Scrollview = require 'famous/views/Scrollview'
Surface = require 'famous/core/Surface'
ListItemView = require 'views/ListItemView'
PlayStore = require 'stores/PlayStore'

class ChoicesView extends View
  @DEFAULT_OPTIONS:
    width: null
    height: 40
    padding: 40
    innerWidth: window.innerWidth - window.innerWidth * .2

  constructor: () ->
    super

  load: (cardId) ->
    choices = PlayStore.getChoices(cardId)
    choiceSurfaces = []
    scrollview = new Scrollview
    scrollview.sequenceFrom choiceSurfaces
    i=0
    for choice in choices
      choiceText = choice.text
      if choiceText
        if choiceText.length > 30
          height = Math.floor(choiceText.length/30) * @options.height
        else
          height = @options.height
        choiceSurface = new Surface
          size: [ @options.width, height ]
          classes: ['card__front__option']
          content: "
                    <div class='outerContainer' style='width: #{@options.innerWidth}px; height: #{height}px;'>
                      <div class='innerContainer'>
                       #{choiceText}
                      </div>
                    </div>"
        choiceSurface.on 'click', ((i) ->
          @_eventOutput.emit 'choice', i
        ).bind @, i
        choiceSurface.on 'scroll', =>
          @_eventOutput.emit 'scroll'
        choiceSurfaces.push choiceSurface
        choiceSurface.pipe scrollview
        i++

    #newChoice = new Surface
    #  size: [ @options.width - 50, @options.height ]
    #  content: "<input type='text' name='newOption' placeholder='Type your own...'>"
    #  classes: ['card__front__input']
    #surfaces.push newChoice

    container = new ContainerSurface
      size: [@options.width, 220]
      properties:
        overflow: "hidden"
      classes: ['card__options__box']

    container.add scrollview
    @add container

module.exports = ChoicesView
