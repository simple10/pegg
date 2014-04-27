Backbone = require 'backbone'

class Question extends Backbone.Model
  defaults:
    question: ''
    mood: ''

module.exports = Question
