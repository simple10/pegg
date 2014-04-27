# CSS
require 'styles/app'
require 'famous/core/famous.css'

# JS
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'


Engine = require 'famous/core/Engine'
Utility = require 'famous/utilities/Utility'
Surface = require 'famous/core/Surface'
ScrollView = require 'famous/views/Scrollview'
HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'

# Views
HeaderView = require 'views/HeaderView'
EditQuestionView = require 'views/EditQuestionView'
ListQuestionsView = require 'views/ListQuestionsView'
ImageUploadView = require 'views/ImageUploadView'
FpsMeter = require 'widgets/FpsMeter'
Mascot = require 'widgets/Mascot'

# Models
Questions = require 'collections/Questions'
Question = require 'models/Question'

# create the main context
mainContext = Engine.createContext()

# Build main view
content = new ScrollView
  direction: Utility.Direction.Y

editQuestion = new EditQuestionView {}
imageUpload = new ImageUploadView {}

questions = new Questions
query = new Parse.Query Question
query.exists 'title'
questions.query = query;
questions.fetch success: (collection) ->
  #console.log collection.toJSON()
  listQuestions = new ListQuestionsView questions

  content.sequenceFrom [
    #editQuestion
    #imageUpload
    listQuestions
  ]

  # Build layout
  layout = new HeaderFooterLayout
    headerSize: 60
    footerSize: 50
  header = new HeaderView
  footer = new Surface
    content: 'by Gratzi'
    classes: ['footer']

  layout.header.add header
  layout.content.add content
  layout.footer.add footer

  # Add views to context
  mainContext.add layout

  # mainContext.add new Mascot
  mainContext.add new FpsMeter

