_ = require("underscore")
importer =
  start: (request, response) ->
    @response = response
    @user = Parse.User.current()

    # XXX this shouldn't be necessary if we call functions with useMasterKey: true
    # It's a bug: https://developers.facebook.com/bugs/306759706140811/
    # It's fixed in the latest JS SDK version
    Parse.Cloud.useMasterKey()
    @getFbFriends()
      .then(@getPeggUsersFromFbFriends.bind(this))
      .then(@updatePermissions.bind(this))
      .then(@finish.bind(this)).fail (error) ->
        response.error error

  getFbFriends: ->
    promise = new Parse.Promise()
    token = @user.attributes.authData.facebook.access_token
    url = "https://graph.facebook.com/me/friends?fields=id&access_token=" + token
    @_getFbFriends url, promise, []
    promise

  _getFbFriends: (url, promise, friends) ->
    Parse.Cloud.httpRequest
      url: url
      success: ((results) ->
        friends = friends.concat(results.data.data)
        if results.data.paging and results.data.paging.next
          @_getFbFriends results.data.paging.next, promise, friends
        else
          @fbFriends = friends
          promise.resolve()
      ).bind(this)
      error: (httpResponse) ->
        promise.reject httpResponse

  getPeggUsersFromFbFriends: ->
    promise = new Parse.Promise()
    friendsArray = _.map(@fbFriends, (friend) ->
      friend.id
    )
    query = new Parse.Query(Parse.User)
    query.containedIn "facebook_id", friendsArray
    query.find
      success: ((res) ->
        @peggFriends = res
        promise.resolve()
      ).bind(this)
      error: (error) ->
        promise.reject error
    promise

  updatePermissions: ->
    promise = new Parse.Promise()

    # ADD friends to user's Role
    query = new Parse.Query Parse.Role
    fbFriendsRoleName = "#{@user.id}_FacebookFriends"
    query.equalTo "name", fbFriendsRoleName
    query.find
      success: ((results) ->
        if results.length is 0
          # create a role that lists user's friends from Facebook
          fbFriendsRole = new Parse.Role(fbFriendsRoleName, new Parse.ACL())
          if @peggFriends.length > 0
            fbFriendsRole.getUsers().add @peggFriends
          fbFriendsRole.save().then((->
            # create a role that can see user's cards
            parentRoleName = "#{@user.id}_Friends"
            parentACL = new Parse.ACL()
            parentRole = new Parse.Role(parentRoleName, parentACL)
            parentRole.getRoles().add fbFriendsRole
            parentRole.save()
            promise.resolve()
          ).bind(this)).fail (error) ->
            promise.reject error
        else if results.length is 1
          # role exists, just need to update friends list
          fbFriendsRole = results[0]
          relation = fbFriendsRole.getUsers()
          # dump old friends
          query = relation.query()
          query.find
            success: (friends) ->
              relation.remove friends
            error: (error) ->
              promise.reject error
          # add current friends
          if @peggFriends.length > 0
            relation.add @peggFriends
          fbFriendsRole.save()
          promise.resolve()
        else
          promise.reject "Something went wrong. There should only be one role called #{fbFriendsRoleName}, but we have #{results.length} of them."
      ).bind(this)
      error: (error) ->
        promise.reject error

    # ADD user to friends' roles
    for peggFriend in @peggFriends
      query = new Parse.Query(Parse.Role)
      fbFriendRoleName = peggFriend.id + "_FacebookFriends"
      console.log fbFriendRoleName
      query.equalTo "name", fbFriendRoleName
      query.find
        success: ((results) ->
          if results.length is 1
            fbFriendsRole = results[0]
            relation = fbFriendsRole.getUsers()
            relation.add @user.id
            fbFriendsRole.save()
        ).bind(this)
        error: (error) ->
          promise.reject error
    promise

  finish: ->
    message = "Updated #{@user.attributes.first_name}'s friends from Facebook (Pegg user id #{@user.id})"
    @response.success message


# Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define "importFriends", importer.start.bind(importer)

Parse.Cloud.define "hasPreffed", (request, response) ->
  cardQuery = new Parse.Query("Card")
  cardQuery.equalTo "objectId", request.params.card
  cardQuery.first
    success: (card) ->
      card.addUnique "hasPreffed", Parse.User.current().id
      card.save()
      response.success "hasPreffed saved"
    error: ->
      response.error "hasPreffed failed"

Parse.Cloud.define "hasPegged", (request, response) ->
  Parse.Cloud.useMasterKey()
  card = new Parse.Object("Card")
  card.set "id", request.params.card
  peggee = new Parse.Object("User")
  peggee.set "id", request.params.peggee
  prefQuery = new Parse.Query("Pref")
  prefQuery.equalTo "card", card
  prefQuery.equalTo "user", peggee
  prefQuery.first
    success: (pref) ->
      pref.addUnique "hasPegged", Parse.User.current().id
      pref.save()
      response.success "hasPegged saved"
    error: ->
      response.error "hasPegged failed"
      return
  return

Parse.Cloud.define "hasViewedPegg", (request, response) ->
  Parse.Cloud.useMasterKey()
  card = new Parse.Object("Card")
  card.set "id", request.params.card
  user = new Parse.Object("User")
  user.set "id", request.params.user
  peggee = new Parse.Object("User")
  peggee.set "id", request.params.peggee
  peggQuery = new Parse.Query("Pegg")
  peggQuery.equalTo "card", card
  peggQuery.equalTo "user", user
  peggQuery.equalTo "peggee", peggee
  peggQuery.first
    success: (pref) ->
      pref.addUnique "hasViewed", Parse.User.current().id
      pref.save()
      response.success "hasViewed saved"
      return
    error: ->
      response.error "hasViewed failed"
      return
  return
