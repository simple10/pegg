# CSS
require 'styles/app'
require 'famous/core/famous.css'

# Polyfills
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'

# Famous
Engine = require 'famous/core/Engine'

# Views
AppView = require 'views/AppView'
FpsMeter = require 'widgets/FpsMeter'
Mascot = require 'widgets/Mascot'

# create the main context
mainContext = Engine.createContext()

mainContext.add new AppView
mainContext.add new Mascot
mainContext.add new FpsMeter

# questions = new Questions
# query = new Parse.Query Question
# query.exists 'title'
# #query.limit 1
# query.skip 10
# questions.query = query;
# questions.fetch success: (collection) ->
#   console.log collection.toJSON()
#   #listQuestions = new ListQuestionsView questions
#   question = new QuestionView collection


#   content.sequenceFrom [
#     #editQuestion
#     #imageUpload
#     #listQuestions
#     #imageEdit
#     question
#   ]

#   # Add views to context
#   mainContext.add layout
