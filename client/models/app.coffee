Backbone = require 'backbone'
DefaultQuestions = require "models/DefaultQuestions"
Questions = require "models/Questions"


module.exports = Backbone.Model.extend(
  initialize: (params) ->
    @fetch()
    return

  fetch: ->
    @set "questions", new Questions(DefaultQuestions)
    return
)
