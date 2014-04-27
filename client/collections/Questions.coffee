Backbone = require 'backbone'
Question = require 'models/Question'

class Questions extends Backbone.Collection
  model: Question

module.exports = Questions
