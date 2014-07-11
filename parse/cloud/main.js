
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("importFriends", function(request, response) {
  var user = Parse.User.current();
  var token = request.params.token;
  getFbFriends(token, response);
});


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


