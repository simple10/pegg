Parse = require 'parse'
Question = require 'models/Question'

class Questions extends Parse.Collection
  model: Question

module.exports = Questions