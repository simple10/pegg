View = require 'famous/src/core/View'
Surface = require 'famous/src/core/Surface'
ContainerSurface = require 'famous/src/surfaces/ContainerSurface'
ImageSurface = require 'famous/src/surfaces/ImageSurface'
StateModifier = require 'famous/src/modifiers/StateModifier'
Transform = require 'famous/src/core/Transform'
Easing = require 'famous/src/transitions/Easing'

UserStore = require 'stores/UserStore'
NavActions = require 'actions/NavActions'
Utils = require 'lib/Utils'

class ProfileHeaderView extends View

  @DEFAULT_OPTIONS:
    avatarWidth: 150
    avatarHeight: 150
    width: Utils.getViewportWidth()
    height: 200
    avatar: ''
    firstname: ''
    bio: 'User one liner here'

  constructor: (options) ->
    super options

    @init()

  init: ->
    @mainMod = new StateModifier
      origin: [0,0]
      align: [0,0]
      size: [@options.width, @options.height]

    @backing = new Surface
      size: [@options.width, @options.height]
      classes: ['profileHeader', 'profileHeader__backing']

    # @picContainer = new ContainerSurface
    #   size: [@options.width, @options.height]
    #   classes: ['profilePic']
    #   properties:
    #     overflow: 'hidden'
    
    @pic = new ImageSurface
      size: [ @options.avatarWidth, @options.avatarWidth]
      content: @options.avatar
      classes: ['profileHeader', 'profile__pic']
      properties:
        borderRadius: '99em'
    picMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 0]
    
    @name = new Surface
      size: [270, 35]
      classes: ['profileHeader', 'profile__name__box']
      content: "#{@options.firstname}'s <strong>profile</strong>"
    nameMod = new StateModifier
      align: [0.5, 0]
      origin: [0.5, 1]

    @bio = new Surface
      size: [@options.width - 50, 25]
      classes: ['profileHeader', 'profile__bio__box']
      content: @options.bio
      properties:
        textAlign: 'center'
        color: 'white'
    bioMod = new StateModifier
      align: [0.5, 0.95]
      origin: [0.5, 1]

    logout = new Surface
      size: [ 200 , 50 ]
      content: 'Logout'
      classes: ['profileHeader', 'profile__logout']
    logoutMod = new StateModifier
      align: [0.5, 0.95]
      origin: [0.5, 1]
    logout.on 'click', ->
      UserStore.logout()
      NavActions.logout()


    node = @add @mainMod
    # @picContainer.add @pic
    # node.add(picMod).add @picContainer
    node.add @backing
    node.add(picMod).add @pic
    node.add(nameMod).add @name
    node.add(bioMod).add @bio
    node.add(logoutMod).add logout

    nameMod.setTransform Transform.translate(0, 160, 0), {duration: 500, easing: Easing.outCubic}

  setAvatar: (url) ->
    @setOptions({
      avatar: url
    })
    @pic.setContent url

  setFirstname: (name) ->
    @setOptions({
      firstname: name
    })
    @name.setContent "#{@options.firstname}'s <strong>profile</strong>"

module.exports = ProfileHeaderView
