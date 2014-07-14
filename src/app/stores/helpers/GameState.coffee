EventHandler = require 'famous/core/EventHandler'
StageState = require 'stores/helpers/StageState'

class GameState extends EventHandler
  constructor: (data) ->
    super
    @_stages = for stageData in data
      stage = new StageState stageData
      stage.pipe @
      stage

  loadNextStage: ->
    # Start with the first stage
    if @_currentStageIdx? then @_currentStageIdx++ else @_currentStageIdx = 0
    @_currentStage = @_stages[@_currentStageIdx]

    # Start over from the first stage if all stages have been loaded
    if !@_currentStage?
      @_currentStageIdx = 0
      @_currentStage = @_stages[@_currentStageIdx]
    @_currentStage.load()
    @_currentStage

  getCards: ->
    @_currentStage.getCardSet()

  getChoices: (cardId) ->
    @_currentStage.getChoices(cardId)


module.exports = GameState
