var _ = require('underscore');

var importer = {
  start: function(request, response) {
    this.response = response;
    this.user = Parse.User.current();
    // XXX this shouldn't be necessary if we call functions with useMasterKey: true
    // It's a bug: https://developers.facebook.com/bugs/306759706140811/
    // It's fixed in the latest JS SDK version
    Parse.Cloud.useMasterKey();
    this.getFbFriends()
      .then(this.getPeggUsersFromFbFriends.bind(this))
      .then(this.updatePermissions.bind(this))
      .then(this.finish.bind(this))
      .fail(function (error) { response.error(error) });
  },

  getFbFriends: function () {
    var promise = new Parse.Promise();
    var token = this.user.attributes.authData.facebook.access_token;
    var url = 'https://graph.facebook.com/me/friends?fields=id&access_token='+token;
    this._getFbFriends(url, promise, []);
    return promise;
  },

  _getFbFriends: function (url, promise, friends) {
    Parse.Cloud.httpRequest({
      url: url,
      success: function(results) {
        friends = friends.concat(results.data.data);
        if (results.data.paging.next) {
          this._getFbFriends(results.data.paging.next, promise, friends);
        } else {
          this.fbFriends = friends;
          promise.resolve()
        }
      }.bind(this),
      error: function(httpResponse) {
        promise.reject(httpResponse);
      }
    });
  },

  getPeggUsersFromFbFriends: function () {
    var promise = new Parse.Promise();
    var friendsArray = _.map(this.fbFriends, function (friend) { return friend.id });
    var query = new Parse.Query(Parse.User);
    query.containedIn("facebook_id", friendsArray);
    query.find({
      success: function (res) {
        this.peggFriends = res;
        promise.resolve();
      }.bind(this),
      error: function (error) {
        promise.reject(error);
      }
    });
    return promise;
  },

  updatePermissions: function () {
    var promise = new Parse.Promise();

    var query = new Parse.Query(Parse.Role);
    var fbFriendsRoleName = this.user.id + "_FacebookFriends";
    query.equalTo("name", fbFriendsRoleName);
    query.find({
      userMasterKey: true,
      success: function (results) {
        if (results.length === 0) {
          //create a role that lists user's friends from Facebook
          var fbFriendsRole = new Parse.Role(fbFriendsRoleName, new Parse.ACL());
          fbFriendsRole.getUsers().add(this.peggFriends);
          fbFriendsRole.save().then(function () {
            //create a role that can see user's cards
            var cardsRoleName = this.user.id +"_Friends";
            var cardsACL = new Parse.ACL();
            var cardsRole = new Parse.Role(cardsRoleName, cardsACL);
            cardsRole.getRoles().add(fbFriendsRole);
            cardsRole.save();
            promise.resolve();
          }.bind(this)).fail(function (error) { promise.reject(error) });
        } else if (results.length === 1) {
          // role exists, just need to update friends list
          var fbFriendsRole = results[0];
          var relation = fbFriendsRole.getUsers();
          // dump old friends
          var query = relation.query();
          query.find({
            success: function (friends) {
              relation.remove(friends);
            },
            error: function (error) { promise.reject(error) }
          });
          // add current friends
          relation.add(this.peggFriends);
          fbFriendsRole.save({ userMasterKey: true });
          promise.resolve();
        } else {
          promise.reject("Something went wrong. There should only be one role called "+ fbFriendsRoleName
                         +", but we have "+ results.length +" of them.");
        }
      }.bind(this),
      error: function (error) { promise.reject(error) }
    });

    return promise;
  },

  finish: function () {
    var message = "Updated "+ this.user.attributes.first_name +"'s friends from Facebook (Pegg user id "+ this.user.id +")";
    this.response.success(message);
  }
}

// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("importFriends", importer.start.bind(importer));
