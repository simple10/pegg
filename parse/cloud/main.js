(function() {
  var importer, _,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ = require("underscore");

  importer = {
    start: function(request, response) {
      this.response = response;
      this.user = Parse.User.current();
      Parse.Cloud.useMasterKey();
      return this.getFbFriends().then(this.getPeggUsersFromFbFriends.bind(this)).then(this.updateForwardPermissions.bind(this)).then(this.updateBackwardPermissions.bind(this)).then(this.finish.bind(this)).fail(function(error) {
        return response.error(error);
      });
    },
    getFbFriends: function() {
      var promise, token, url;
      promise = new Parse.Promise();
      token = this.user.attributes.authData.facebook.access_token;
      url = "https://graph.facebook.com/me/friends?fields=id&access_token=" + token;
      this._getFbFriends(url, promise, []);
      return promise;
    },
    _getFbFriends: function(url, promise, friends) {
      return Parse.Cloud.httpRequest({
        url: url,
        success: (function(results) {
          friends = friends.concat(results.data.data);
          if (results.data.paging && results.data.paging.next) {
            return this._getFbFriends(results.data.paging.next, promise, friends);
          } else {
            this.fbFriends = friends;
            return promise.resolve();
          }
        }).bind(this),
        error: function(httpResponse) {
          return promise.reject(httpResponse);
        }
      });
    },
    getPeggUsersFromFbFriends: function() {
      var friendsArray, promise, query;
      promise = new Parse.Promise();
      friendsArray = _.map(this.fbFriends, function(friend) {
        return friend.id;
      });
      query = new Parse.Query(Parse.User);
      query.containedIn("facebook_id", friendsArray);
      query.find({
        success: (function(res) {
          this.peggFriends = res;
          return promise.resolve();
        }).bind(this),
        error: function(error) {
          return promise.reject(error);
        }
      });
      return promise;
    },
    updateForwardPermissions: function() {
      var fbFriendsRoleName, promise, query;
      promise = new Parse.Promise();
      query = new Parse.Query(Parse.Role);
      fbFriendsRoleName = "" + this.user.id + "_FacebookFriends";
      query.equalTo("name", fbFriendsRoleName);
      query.find({
        success: (function(results) {
          var fbFriendsRole, relation;
          if (results.length === 0) {
            fbFriendsRole = new Parse.Role(fbFriendsRoleName, new Parse.ACL());
            if (this.peggFriends.length > 0) {
              fbFriendsRole.getUsers().add(this.peggFriends);
            }
            return fbFriendsRole.save().then((function() {
              var parentACL, parentRole, parentRoleName;
              parentRoleName = "" + this.user.id + "_Friends";
              parentACL = new Parse.ACL();
              parentRole = new Parse.Role(parentRoleName, parentACL);
              parentRole.getRoles().add(fbFriendsRole);
              parentRole.save();
              return promise.resolve();
            }).bind(this)).fail(function(error) {
              return promise.reject(error);
            });
          } else if (results.length === 1) {
            fbFriendsRole = results[0];
            relation = fbFriendsRole.getUsers();
            query = relation.query();
            query.find({
              success: function(friends) {
                return relation.remove(friends);
              },
              error: function(error) {
                return promise.reject(error);
              }
            });
            if (this.peggFriends.length > 0) {
              relation.add(this.peggFriends);
            }
            fbFriendsRole.save();
            return promise.resolve();
          } else {
            return promise.reject("Something went wrong. There should only be one role called " + fbFriendsRoleName + ", but we have " + results.length + " of them.");
          }
        }).bind(this),
        error: function(error) {
          return promise.reject(error);
        }
      });
      return promise;
    },
    updateBackwardPermissions: function() {
      var promise;
      promise = new Parse.Promise();
      if (this.peggFriends.length > 0) {
        return this._updateFriendRole(promise, 0);
      }
    },
    _updateFriendRole: function(promise, index) {
      var fbFriendRoleName, query;
      query = new Parse.Query(Parse.Role);
      fbFriendRoleName = "" + this.peggFriends[index].id + "_FacebookFriends";
      console.log(fbFriendRoleName);
      query.equalTo('name', fbFriendRoleName);
      return query.find({
        success: (function(results) {
          var fbFriendsRole, friend, relation;
          if (results.length === 1) {
            fbFriendsRole = results[0];
            relation = fbFriendsRole.getUsers();
            friend = new Parse.Object('User');
            friend.set('id', this.user.id);
            relation.add(friend);
            fbFriendsRole.save();
            if (index === this.peggFriends.length - 1) {
              return promise.resolve();
            } else {
              return this._updateFriendRole(promise, index++);
            }
          }
        }).bind(this),
        error: function(error) {
          return promise.reject(error);
        }
      });
    },
    finish: function() {
      var message;
      message = "Updated " + this.user.attributes.first_name + "'s friends from Facebook (Pegg user id " + this.user.id + ")";
      return this.response.success(message);
    }
  };

  Parse.Cloud.define("importFriends", importer.start.bind(importer));

  Parse.Cloud.define("hasPreffed", function(request, response) {
    var cardQuery;
    cardQuery = new Parse.Query('Card');
    cardQuery.equalTo("objectId", request.params.card);
    return cardQuery.first({
      success: function(card) {
        card.addUnique("hasPreffed", Parse.User.current().id);
        card.save();
        return response.success("hasPreffed saved");
      },
      error: function() {
        return response.error("hasPreffed failed");
      }
    });
  });

  Parse.Cloud.define("hasPegged", function(request, response) {
    var card, peggee, prefQuery;
    Parse.Cloud.useMasterKey();
    card = new Parse.Object("Card");
    card.set("id", request.params.card);
    peggee = new Parse.Object("User");
    peggee.set("id", request.params.peggee);
    prefQuery = new Parse.Query("Pref");
    prefQuery.equalTo("card", card);
    prefQuery.equalTo("user", peggee);
    return prefQuery.first({
      success: function(pref) {
        pref.addUnique("hasPegged", Parse.User.current().id);
        pref.save();
        return response.success("hasPegged saved");
      },
      error: function() {
        return response.error("hasPegged failed");
      }
    });
  });

  Parse.Cloud.define("hasViewedPegg", function(request, response) {
    var card, peggQuery, peggee, user;
    Parse.Cloud.useMasterKey();
    card = new Parse.Object("Card");
    card.set("id", request.params.card);
    user = new Parse.Object("User");
    user.set("id", request.params.user);
    peggee = new Parse.Object("User");
    peggee.set("id", request.params.peggee);
    peggQuery = new Parse.Query("Pegg");
    peggQuery.equalTo("card", card);
    peggQuery.equalTo("user", user);
    peggQuery.equalTo("peggee", peggee);
    return peggQuery.first({
      success: function(pref) {
        pref.addUnique("hasViewed", Parse.User.current().id);
        pref.save();
        return response.success("hasViewed saved");
      },
      error: function() {
        return response.error("hasViewed failed");
      }
    });
  });

  Parse.Cloud.afterSave('Pegg', function(request) {
    var card, cardId, peggee, peggeeId, pegger, prefQuery, userId;
    userId = Parse.User.current().id;
    Parse.Cloud.useMasterKey();
    cardId = request.object.get('card').id;
    peggeeId = request.object.get('peggee').id;
    card = new Parse.Object('Card');
    card.set('id', cardId);
    peggee = new Parse.Object('User');
    peggee.set('id', peggeeId);
    pegger = new Parse.Object('User');
    pegger.set('id', userId);
    prefQuery = new Parse.Query('Pref');
    prefQuery.equalTo('card', card);
    prefQuery.equalTo('user', peggee);
    return prefQuery.first({
      success: function(pref) {
        pref.addUnique('hasPegged', userId);
        pref.save();
        return console.log("hasPegged saved: " + pref.id);
      },
      error: function() {
        return console.log('hasPegged failed');
      }
    });
  });

  Parse.Cloud.afterSave('Pref', function(request) {
    var cardId, cardQuery, userId;
    userId = Parse.User.current().id;
    Parse.Cloud.useMasterKey();
    cardId = request.object.get('card').id;
    cardQuery = new Parse.Query('Card');
    cardQuery.equalTo('objectId', cardId);
    return cardQuery.first({
      success: function(card) {
        var cardAcl;
        cardAcl = card.get('ACL');
        if (cardAcl !== void 0) {
          console.log("ACL added to card " + card.id + ": " + userId + "_Friends");
          cardAcl.setRoleReadAccess("" + userId + "_Friends", true);
          card.setACL(cardAcl);
        }
        card.addUnique('hasPreffed', userId);
        card.save();
        return console.log("hasPreffed saved: " + card.id);
      },
      error: function() {
        return console.log('hasPreffed failed');
      }
    });
  });

  Parse.Cloud.afterSave('Points', function(request) {
    var badgesQuery, user, userId;
    userId = Parse.User.current().id;
    Parse.Cloud.useMasterKey();
    user = new Parse.Object('User');
    user.set('id', userId);
    badgesQuery = new Parse.Query('Badges');
    return badgesQuery.find({
      success: function(badges) {
        var pointsQuery;
        pointsQuery = new Parse.Query('Points');
        pointsQuery.equalTo('pegger', user);
        return pointsQuery.find({
          success: function(points) {
            var pointRow, totalPoints, userBadgesQuery, _i, _len;
            totalPoints = 0;
            for (_i = 0, _len = points.length; _i < _len; _i++) {
              pointRow = points[_i];
              totalPoints += pointRow.get('points');
            }
            console.log('totalPoints: ' + totalPoints);
            userBadgesQuery = new Parse.Query('UserBadges');
            userBadgesQuery.equalTo('user', user);
            return userBadgesQuery.find({
              success: function(userBadges) {
                var badgeCriteria, badgeRow, newUserBadge, newUserBadgeAcl, userBadgesIDs, _j, _len1, _ref, _results;
                userBadgesIDs = _.map(userBadges, function(userBadge) {
                  return userBadge.get('badge').id;
                });
                _results = [];
                for (_j = 0, _len1 = badges.length; _j < _len1; _j++) {
                  badgeRow = badges[_j];
                  badgeCriteria = badgeRow.get('criteria');
                  if (totalPoints >= badgeCriteria.points) {
                    console.log('user: ' + user.id);
                    console.log("badgeID: " + badgeRow.id);
                    console.log('userBadgesIDs: ' + userBadgesIDs);
                    if (_ref = badgeRow.id, __indexOf.call(userBadgesIDs, _ref) < 0) {
                      newUserBadgeAcl = new Parse.ACL(user);
                      newUserBadgeAcl.setPublicReadAccess(true);
                      newUserBadge = new Parse.Object('UserBadges');
                      newUserBadge.set('badge', badgeRow);
                      newUserBadge.set('user', user);
                      newUserBadge.set('hasViewed', false);
                      newUserBadge.set('ACL', newUserBadgeAcl);
                      _results.push(newUserBadge.save());
                    } else {
                      _results.push(void 0);
                    }
                  } else {
                    _results.push(void 0);
                  }
                }
                return _results;
              },
              error: function() {
                return console.log('get UserBadges failed');
              }
            });
          },
          error: function() {
            return console.log('get Points failed');
          }
        });
      },
      error: function() {
        return console.log('get Badges failed');
      }
    });
  });

}).call(this);
