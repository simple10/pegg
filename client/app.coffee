# CSS
require 'styles/app'
require 'famous/core/famous.css'

# JS
require 'famous-polyfills/functionPrototypeBind'
require 'famous-polyfills/classList'
require 'famous-polyfills/requestAnimationFrame'


Engine = require 'famous/core/Engine'
Modifier = require 'famous/core/Modifier'
Utility = require 'famous/utilities/Utility'

Surface = require 'famous/core/Surface'

HeaderFooterLayout = require 'famous/views/HeaderFooterLayout'
ScrollView = require 'famous/views/ScrollView'

HeaderView = require 'views/HeaderView'
EditQuestionView = require 'views/EditQuestionView'
ImageUploadView = require 'views/ImageUploadView'

#require 'facebook'


# HomePage = require 'pages/home'
# CreateQuestionPage = require 'pages/questions/create'


# Routes


#globals define


# create the main context
mainContext = Engine.createContext()



# Build main view

content = new ScrollView
  direction: Utility.Direction.Y




# Build layout

layout = new HeaderFooterLayout
  headerSize: 60
  footerSize: 50

header = new HeaderView

footer = new Surface
  content: "Footer"
  classes: ['footer']

editQuestion = new EditQuestionView {}
#imageUpload = new ImageUploadView
content.sequenceFrom [
  editQuestion
#  imageUpload
]


layout.header.add header
layout.content.add content
layout.footer.add footer

mainContext.add layout







