Parse = require 'Parse'

Comment = Parse.Object.extend 'Comment'
Card = Parse.Object.extend 'Card'
Choice = Parse.Object.extend 'Choice'
Pref = Parse.Object.extend 'Pref'
Pegg = Parse.Object.extend 'Pegg'
Points = Parse.Object.extend 'Points'
PrefCounts = Parse.Object.extend 'PrefCounts'


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

  savePlug: (cardId, imageUrl, peggeeId, cb) ->
    # UPDATE Pref table with user's new image
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    prefQuery = new Parse.Query Pref
    prefQuery.equalTo 'user', peggee
    prefQuery.equalTo 'card', card
    prefQuery.first
      success: (results) =>
        results.set 'plug', imageUrl
        results.save()
        cb "Plug saved: #{imageUrl}"
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"
        cb null


  savePrefCount: (cardId, choiceId, cb) ->
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    
    prefCount = new Parse.Object 'PrefCounts'
    prefCount.set 'card', card
    prefCount.set 'choice', choice
    
    @getPrefCount choiceId, (res) =>
      # if it already exists... update it
      if res
        count = res.get 'count'
        count = count + 1
        res.set 'count', count
        res.save()
      # otherwise create a new object and save
      else 
        prefCount.set 'count', 1
        prefCount.save()

      cb 'savePrefCounts done'

  savePoints: (peggerId, peggeeId, points, cb) ->
    # UPDATE points row with new points
    pointsQuery = new Parse.Query 'Points'
    pegger = new Parse.Object 'User'
    pegger.set 'id',  peggerId
    peggee = new Parse.Object 'User'
    peggee.set 'id',  peggeeId
    pointsQuery.equalTo 'pegger', pegger
    pointsQuery.equalTo 'peggee', peggee
    pointsQuery.first
      success: (results) =>
        if results?
          points = results.get('points') + points
          cardsPlayed = results.get('cardsPlayed') + 1
          results.set 'cardsPlayed', cardsPlayed
          results.set 'points', points
          results.save()
        else
          newPointsAcl = new Parse.ACL pegger
          #newPointsAcl.setRoleReadAccess "#{peggeeId}_Friends", true
          newPointsAcl.setPublicReadAccess true
          newPoints = new Parse.Object 'Points'
          newPoints.set 'pegger', pegger
          newPoints.set 'peggee', peggee
          newPoints.set 'points', points
          newPoints.set 'cardsPlayed', 1
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
    #prefQuery.containedIn 'hasPegged', [user.id]
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

  getPrefChoices: (cards, cardId, cb) ->
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

  getPeggChoices: (cards, cardId, peggeeId, cb) ->
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    prefQuery = new Parse.Query Pref
    prefQuery.include 'answer'
    prefQuery.equalTo 'user', peggee
    prefQuery.equalTo 'card', card
    prefQuery.first
      success: (results) =>
        if results? and results.get('plug')?
          cards[cardId].choices.push
            id: results.get('answer').id
            text: results.get('answer').get 'text'
            image: results.get 'plug'
          debugger
        @getPrefChoices(cards, cardId, cb)
      error: (error) ->
        console.log "Error fetching choices: " + error.code + " " + error.message
        cb null

#
#    choiceQuery = new Parse.Query Choice
#    choiceQuery.equalTo 'cardId', cardId
#    choiceQuery.find
#      success: (choices) =>
#        cards[cardId].choices = []
#        for choice in choices
#          cards[cardId].choices.push
#            id: choice.id
#            text: choice.get 'text'
#            image: choice.get 'image'
#        cb cards
#      error: (error) ->
#        console.log "Error fetching choices: " + error.code + " " + error.message
#        cb null

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

  getTopScores: (peggeeId, cb) ->
    scores = []
    pointsQuery = new Parse.Query Points
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    pointsQuery.equalTo 'peggee', peggee
    pointsQuery.descending 'points'
    pointsQuery.include 'peggee'
    pointsQuery.include 'pegger'
    pointsQuery.find
      success: (results) =>
        for score in results
          scores.push {
            peggee: score.get 'peggee'
            pegger: score.get 'pegger'
            points: score.get 'points'
            cardsPlayed: score.get 'cardsPlayed'
          }
        cb scores
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null

  getPrefCount: (choiceId, cb) ->
    choice = new Parse.Object 'Choice'
    choice.set 'id', choiceId
    prefCountQuery = new Parse.Query PrefCounts
    prefCountQuery.equalTo 'choice', choice
    prefCountQuery.first
      success: (result) =>
        cb result
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null


  getPrefCounts: (cards, cb) ->
    cardObjs = []
    for own id, card of cards
      cardObj = new Parse.Object 'Card'
      cardObj.set 'id', id
      cardObjs.push cardObj
    prefCountsQuery = new Parse.Query PrefCounts
    prefCountsQuery.containedIn 'card', cardObjs
    prefCountsQuery.include 'card'
    prefCountsQuery.include 'choice'
    prefCountsQuery.find
      success: (results) =>
        cards = {}
        for res in results
          choice = res.get 'choice'
          count = res.get 'count'
          card = res.get 'card'
          if !cards[card.id]?
            cards[card.id] = {
              question: card.get 'question'
              choices: {}
              total: 0
            }
          cards[card.id].choices[choice.id] = {
            choiceText: choice.get 'text'
            count: count
          }
          cards[card.id].total += count
        cb cards
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null

  saveQuestion: (authorId, question, cb) ->
    user = new Parse.Object 'User'
    user.set 'id',  authorId
    newCardAcl = new Parse.ACL user
    newCardAcl.setRoleReadAccess "#{authorId}_Friends", true
    newCard = new Parse.Object 'Card'
    newCard.set 'question', question
    newCard.set 'ACL', newCardAcl
    newCard.save
      success: (result) =>
        debugger
        cb result.id
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null

  saveChoices: (cardId, answers, cb) ->
    for answer in answers
      newChoice4 = new Parse.Object 'Choice'
      newChoice4.set 'text', answer
      newChoice4.set 'cardId', cardId
      newChoice4.save()

  saveCategories: (cardId, categories, cb) ->
    for category in categories
      newChoice4 = new Parse.Object 'Choice'
      newChoice4.set 'categoryId', category.Id
      newChoice4.set 'cardId', cardId
      newChoice4.save()

parse = new ParseBackend()

module.exports = parse
