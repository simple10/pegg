var _ = require('underscore');

// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("importFriends", function(request, response) {
  var user = Parse.User.current();
  var token = user.attributes.authData.facebook.access_token;
  getFbFriends(token, {
    success: function (friends) { getPeggUsersFromFbFriends(response, friends) },
    error: function (error) { response.error(error) }
  });
});

function getPeggUsersFromFbFriends(response, friends) {
  var friendsArray = _.map(friends, function (friend) { return friend.id });
  var query = new Parse.Query(Parse.User);
  query.containedIn("facebook_id", friendsArray);
  query.find({
    success: function (res) {
      response.success(res);
    }
  });
}

function updateACL(response, users) {
}

function getFbFriends(token, response) {
  url = 'https://graph.facebook.com/me/friends?fields=id&access_token='+token;
  _getFbFriends(url, response, []);
}

function _getFbFriends(url, response, friends) {
  Parse.Cloud.httpRequest({
    url: url,
    success: function(results) {
      friends = friends.concat(results.data.data);
      console.log(friends.length);
      if (results.data.paging.next) {
        _getFbFriends(results.data.paging.next, response, friends);
      } else {
        response.success(friends);
      }
    },
    error: function(httpResponse) {
      console.error(httpResponse);
      response.error(httpResponse);
    }
  });
}


