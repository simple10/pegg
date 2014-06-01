AppView = require 'views/AppView'
helper = require '../helpers/Common'
expect = helper.expect
spy = helper.spy


describe 'AppView', ->
  beforeEach ->
    @view = new AppView

  it 'example test', ->
    expect(@view.showPage).to.be.a 'function'

  # Test the showPage instance method indicated by '#'.
  # See http://visionmedia.github.io/mocha/
  # #someName means instance property
  # .someName means prototype or class property
  describe '#showPage', ->

    it 'calls lightbox#show', ->
      # The goal here is to test if the page we pass to #showPage gets
      # shown. We could create an integration tests and actually test the
      # dom to make sure the expected page appears. This may be appropriate
      # in some cases, but interacting with the dom is slow. The other option
      # is to trust that Famo.us's Lightbox component behaves as expected.
      # In this case, we just need to test that the correct Lightbox API
      # method gets called when we call our #showPage method.

      # We can use Sinon.js spies to listen to the #lightbox.show method.
      # With a little added syntactic sugar from sinon-chai
      # https://github.com/domenic/sinon-chai

      page = 'somepage'
      lightbox = @view.lightbox

      # Replace lightbox.show with a spy function
      show = lightbox.show = spy()

      # Run the code
      @view.showPage page

      expect(show).to.have.been.calledWith page


