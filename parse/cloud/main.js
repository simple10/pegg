var _ = require('underscore');

// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("importFriends", importFriends);

function importFriends(request, response) {
  importer.start(request, response)
}

var importer = {
  start: function(request, response) {
    this.response = response;
    this.getFbFriends()
      .done(this.getPeggUsersFromFbFriends.bind(this))
      .done(this.updateAcl.bind(this))
      .done(this.finish.bind(this))
      .fail(function (error) {
        response.error(error);
      })
  },

  getFbFriends: function () {
    var promise = new Parse.Promise();
    var user = Parse.User.current();
    var token = user.attributes.authData.facebook.access_token;
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

  updateAcl: function () {
    var promise = new Parse.Promise();
    promise.reject("implement me");
    return promise;
  },

  finish: function() {
    this.response.success("User's friends updated successfully");
  }
}

