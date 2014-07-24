Parse = require 'Parse'

Comment = Parse.Object.extend 'Comment'
Card = Parse.Object.extend 'Card'
Choice = Parse.Object.extend 'Choice'
Pref = Parse.Object.extend 'Pref'
Pegg = Parse.Object.extend 'Pegg'


class ParseBackend

  saveComment: (comment, cardId, peggeeId, userId, userImg, cb) ->
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    author = new Parse.Object 'User'
    author.set 'id',  userId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    newComment = new Parse.Object 'Comment'
    newCommentAcl = new Parse.ACL author
    newCommentAcl.setRoleReadAccess "#{userId}_Friends", true
    newCommentAcl.setRoleReadAccess "#{peggeeId}_Friends", true
    newComment.set 'peggee', peggee
    newComment.set 'card', card
    newComment.set 'text', comment
    newComment.set 'author', author
    newComment.set 'userImg', userImg
    newComment.set 'ACL', newCommentAcl
    newComment.save()
    cb newComment

  getComments: (cardId, peggeeId, cb) ->
    query = new Parse.Query Comment
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    query.equalTo 'peggee', peggee
    query.equalTo 'card', card
    query.include 'author'
    query.descending 'createdAt'
    query.find
      success: (results) =>
        console.log results
        cb results
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"
        cb null

  savePegg: (peggeeId, cardId, choiceId, answerId, userId, cb) ->
    # INSERT into Pegg table a row with current user's pegg
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    pegger = new Parse.Object 'User'
    pegger.set 'id',  userId
    newPeggAcl = new Parse.ACL pegger
    newPeggAcl.setRoleReadAccess "#{userId}_Friends", true
    peggee = new Parse.Object 'User'
    peggee.set 'id',  peggeeId
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    answer = new Parse.Object 'Choice'
    answer.set 'id', answerId
    newPegg = new Parse.Object 'Pegg'
    newPegg.set 'guess', choice
    newPegg.set 'answer', answer
    newPegg.set 'card', card
    newPegg.set 'user', pegger
    newPegg.set 'ACL', newPeggAcl
    newPegg.set 'peggee', peggee
    newPegg.save()
    cb 'savePegg done'

  savePref: (cardId, choiceId, userId, cb) ->
    # INSERT into Pref table a row with user's choice
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    preffer = new Parse.Object 'User'
    preffer.set 'id',  userId
    newPrefAcl = new Parse.ACL preffer
    newPrefAcl.setRoleReadAccess "#{userId}_Friends", true
    answer = new Parse.Object 'Choice'
    answer.set 'id', choiceId
    newPref = new Parse.Object 'Pref'
    newPref.set 'answer', answer
    newPref.set 'card', card
    newPref.set 'user', preffer
    newPref.set 'ACL', newPrefAcl
    newPref.save()
    cb 'savePref done'

  savePoints: (userId, friendId, points, cb) ->
    # UPDATE points row with new points
    pointsQuery = new Parse.Query 'Points'
    user = new Parse.Object 'User'
    user.set 'id',  userId
    friend = new Parse.Object 'User'
    friend.set 'id',  friendId
    pointsQuery.equalTo 'user', user
    pointsQuery.equalTo 'friend', friend
    pointsQuery.first
      success: (results) =>
        if results?
          points = results.get('points') + points
          results.set 'points', points
          results.save()
          cb points
        else
          newPointsAcl = new Parse.ACL user
          newPointsAcl.setRoleReadAccess "#{userId}_Friends", true
          newPoints = new Parse.Object 'Points'
          newPoints.set 'user', user
          newPoints.set 'friend', friend
          newPoints.set 'points', points
          newPoints.set 'ACL', newPointsAcl
          newPoints.save()
          cb points
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"
        cb null

  getPrefCards: (num, user, cb) ->
    # Gets unanswered preferences: cards the user answers about himself
    cards  = {}
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    cardQuery.notContainedIn 'hasPreffed', [user.id]
    #cardQuery.skip Math.floor(Math.random() * 180)
    cardQuery.find
      success: (results) =>
        for card in results
          cards[card.id] = {
            firstName: user.get 'first_name'
            pic: user.get 'avatar_url'
            question: card.get 'question'
            choices: null
          }
        cb cards
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message
        cb null

  getPeggCards: (num, user, cb) ->
    # Gets unpegged preferences: cards the user answers about a friend
    cards = {}
    prefUser = new Parse.Object 'User'
    prefUser.set 'id', user.id
    prefQuery = new Parse.Query Pref
    prefQuery.limit num
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'answer'
    prefQuery.notEqualTo 'user', prefUser
    #prefQuery.notContainedIn 'hasPegged', [user.id]
    #prefQuery.containedIn 'peggedBy', [user.id]
    #prefQuery.skip Math.floor(Math.random() * 300)
    prefQuery.find
      success: (results) =>
        for pref in results
          card = pref.get 'card'
          peggee = pref.get 'user'
          cards[card.id] = {
            peggee: peggee.id
            firstName: peggee.get 'first_name'
            pic: peggee.get 'avatar_url'
            question: card.get 'question'
            choices: null
            answer: pref.get 'answer'
          }
        cb cards
      error: (error) ->
        console.log "Error fetching cards: " + error.code + " " + error.message
        cb null

  getChoices: (cards, cardId, cb) ->
    choiceQuery = new Parse.Query Choice
    choiceQuery.equalTo 'cardId', cardId
    choiceQuery.find
      success: (choices) =>
        cards[cardId].choices = []
        for choice in choices
          cards[cardId].choices.push
            id: choice.id
            text: choice.get 'text'
            image: choice.get 'image'
        cb cards
      error: (error) ->
        console.log "Error fetching choices: " + error.code + " " + error.message
        cb null

  getActivity: (page, cb) ->
    activities = []
    # TODO: implement pagination
    peggQuery = new Parse.Query Pegg
    peggQuery.include 'card'
    peggQuery.include 'guess'
    peggQuery.include 'peggee'
    peggQuery.include 'user'
    peggQuery.find
      success: (results) =>
        for activity in results
          activities.push {
            pegger: activity.get 'user'
            peggee: activity.get 'peggee'
            card: activity.get 'card'
            guess: activity.get 'guess'
          }
        if results.length
          #console.log @_activity
          cb activities
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        cb null

parse = new ParseBackend()

module.exports = parse
