Parse = require 'Parse'

Comment = Parse.Object.extend 'Comment'
Card = Parse.Object.extend 'Card'
Choice = Parse.Object.extend 'Choice'
Category = Parse.Object.extend 'Category'
Pref = Parse.Object.extend 'Pref'
Pegg = Parse.Object.extend 'Pegg'
Points = Parse.Object.extend 'Points'
PrefCounts = Parse.Object.extend 'PrefCounts'
Activity = Parse.Object.extend 'Activity'
User = Parse.Object.extend 'User'
UserMood = Parse.Object.extend 'UserMood'

class ParseBackend

  saveActivity: (message, pic, userId, cardId, peggeeId) ->
    console.log "saveActivity: ", message, pic, userId, cardId, peggeeId
    user = new Parse.Object 'User'
    user.set 'id',  userId
    newActivityAcl = new Parse.ACL user
    newActivityAcl.setRoleReadAccess "#{userId}_Friends", true
    activity = new Parse.Object 'Activity'
    activity.set 'message', message
    activity.set 'pic', pic
    activity.set 'user', (new Parse.Object 'User').set 'id', userId
    activity.set 'peggee', (new Parse.Object 'User').set 'id', peggeeId if peggeeId?
    activity.set 'card', (new Parse.Object 'Card').set 'id', cardId if cardId?
    activity.set 'ACL', newActivityAcl
    activity.save()

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

  getUser: (userId, cb) ->
    query = new Parse.Query User
    query.equalTo 'objectId', userId
    # promise = Parse.Promise()
    # query.first
    #   success: (result) =>
    #     user = {
    #       firstName: result.get 'first_name'
    #       lastName: result.get 'last_name'
    #       gender: result.get 'gender'
    #       pic: result.get 'avatar_url'
    #     }
    #     promise.resolve user
    #   error: (error) ->
    #     promise.reject error
    # promise
    query.first
      success: (result) =>
        user = {
          firstName: result.get 'first_name'
          lastName: result.get 'last_name'
          gender: result.get 'gender'
          pic: result.get 'avatar_url'
        }
        cb user
      error: (error) ->
        console.log "Error: #{error.code}  #{error.message}"
        cb null

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

  savePegg: (peggeeId, cardId, choiceId, answerId, userId) ->
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

  savePref: (cardId, choiceId, plug, thumb, userId, moodId) ->
    # INSERT into Pref table a row with user's choice
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    preffer = new Parse.Object 'User'
    preffer.set 'id',  userId
    mood = new Parse.Object 'Category'
    mood.set 'id', moodId
    newPrefAcl = new Parse.ACL preffer
    newPrefAcl.setRoleReadAccess "#{userId}_Friends", true
    # newPrefAcl.setPublicReadAccess true
    answer = new Parse.Object 'Choice'
    answer.set 'id', choiceId
    newPref = new Parse.Object 'Pref'
    newPref.set 'answer', answer
    newPref.set 'card', card
    newPref.set 'plug', plug
    newPref.set 'plugThumb', thumb
    newPref.set 'user', preffer
    newPref.set 'mood', mood
    newPref.set 'ACL', newPrefAcl
    newPref.save()

  savePlug: (cardId, full, thumb, peggeeId) ->
    # UPDATE Pref table with user's new image
    card = new Parse.Object 'Card'
    card.set 'id', cardId
    peggee = new Parse.Object 'User'
    peggee.set 'id', peggeeId
    prefQuery = new Parse.Query Pref
    prefQuery.equalTo 'user', peggee
    prefQuery.equalTo 'card', card
    promise = Parse.Promise()
    prefQuery.first
      success: (result) =>
        result.set 'plug', full
        result.set 'plugThumb', thumb
        result.save()
          .then ->
            promise.resolve()
          .fail (error) ->
            promise.reject(error)
      error: (error) ->
        promise.reject(error)
    promise

  # used to display popularity of choices
  savePrefCount: (cardId, choiceId) ->
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


  savePoints: (peggerId, peggeeId, points) ->
    # UPDATE points row with new points
    pointsQuery = new Parse.Query 'Points'
    pegger = new Parse.Object 'User'
    pegger.set 'id',  peggerId
    peggee = new Parse.Object 'User'
    peggee.set 'id',  peggeeId
    pointsQuery.equalTo 'pegger', pegger
    pointsQuery.equalTo 'peggee', peggee
    pointsQuery.first()
      .then (result) =>
        if result?
          points = result.get('points') + points
          cardsPlayed = result.get('cardsPlayed') + 1
          result.set 'cardsPlayed', cardsPlayed
          result.set 'points', points
          result.save()
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
        points

  saveMood: (moodId, userId) ->
    # INSERT into Mood table a row with user's mood
    mood = new Parse.Object 'Category'
    mood.set 'id', moodId
    user = new Parse.Object 'User'
    user.set 'id',  userId
    newUserAcl = new Parse.ACL user
    newUserAcl.setRoleReadAccess "#{userId}_Friends", true
    newMood = new Parse.Object 'UserMood'
    newMood.set 'mood', mood
    newMood.set 'user', user
    newMood.set 'ACL', newUserAcl
    newMood.save()

  getUnpreffedCards: (num, mood, user) ->
    # TODO: change mood to moodId, use Pointers instead of an array in Categories column
    # Gets unanswered preferences: cards the user answers about himself
    cardQuery = new Parse.Query Card
    cardQuery.limit num
    cardQuery.notContainedIn 'hasPreffed', [user.id]
    if mood?
      cardQuery.containedIn 'categories', [mood.text]
    #cardQuery.skip Math.floor(Math.random() * 180)
    cardQuery.find()
      .then (results) =>
        cards = []
        for card in results
          cards.push {
            id: card.id
            firstName: user.get 'first_name'
            pic: user.get 'avatar_url'
            question: card.get 'question'
          }
        cards

  getCategories: (cb) ->
    catQuery = new Parse.Query Category
    catQuery.find
      success: (results) =>
        cb results
      error: (error) ->
        console.log "Error fetching categories: " + error.code + " " + error.message
        cb null

  getPeggCards: (num, user, moodId, peggeeId) ->
    # Gets unpegged preferences: cards the user answers about a friend

    prefUser = new Parse.Object 'User'
    prefUser.set 'id', user.id
    peggeeUser = new Parse.Object 'User'
    peggeeUser.set 'id', peggeeId
    mood = new Parse.Object 'Category'
    mood.set 'id', moodId
    prefQuery = new Parse.Query Pref
    prefQuery.limit num
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'answer'
#    prefQuery.equalTo 'user', peggeeUser if peggeeId?
#    prefQuery.equalTo 'mood', mood if moodId?
    prefQuery.notEqualTo 'user', prefUser
    prefQuery.notContainedIn 'hasPegged', [user.id]
    #prefQuery.containedIn 'hasPegged', [user.id]
    #prefQuery.skip Math.floor(Math.random() * 300)
    prefQuery.find()
      .then (results) =>
        cards = []
        for pref in results
          card = pref.get 'card'
          peggee = pref.get 'user'
          plug = pref.get 'plug'
          if plug? then plug = JSON.parse(plug).S3
          cards.push {
            id: card.id
            peggeeId: peggee.id
            firstName: peggee.get 'first_name' or ''
            pic: peggee.get 'avatar_url' or ''
            question: card.get('question') or ''
            answer:
              id: pref.get('answer').id
              text: pref.get('answer').get('text')
              plug: plug
            hasPreffed: card.get 'hasPreffed'
          }
        cards

  getCard: (cardId, cb) ->
    cardQuery = new Parse.Query Card
    cardQuery.equalTo 'objectId', cardId
    cardQuery.first
      success: (card) =>
        if card?
          cardObj = {
            id: card.id
            question: card.get 'question'
            hasPreffed: card.get 'hasPreffed'
            choices: []
          }
          cb cardObj
        else
          cb null
      error: (error) ->
        console.log "Error fetching card: " + error.code + " " + error.message
        cb null

  getPrefCard: (cardId, peggeeId) ->
    peggee = new Parse.Object 'User'
    peggee.set 'id',  peggeeId
    card = new Parse.Object 'Card'
    card.set 'id',  cardId
    prefQuery = new Parse.Query Pref
    prefQuery.include 'user'
    prefQuery.include 'card'
    prefQuery.include 'answer'
    prefQuery.equalTo 'user', peggee
    prefQuery.equalTo 'card', card
    prefQuery.first()
      .then (pref) =>
        if pref?
          card = pref.get 'card'
          peggee = pref.get 'user'
          plug = pref.get 'plug'
          if plug? then plug = JSON.parse(plug).S3
          cardObj = {
            id: card.id
            peggeeId: peggee.id
            firstName: peggee.get 'first_name'
            pic: peggee.get 'avatar_url'
            gender: peggee.get 'gender'
            hasPegged: pref.get 'hasPegged'
            question: card.get 'question'
            choices: []
            answer:
              id: pref.get('answer').id
              text: pref.get('answer').get('text')
              plug: plug
          }
          cardObj
        else
          null


  getChoices: (cardId) ->
    choiceQuery = new Parse.Query Choice
    card = new Parse.Object 'Card'
    card.set 'id',  cardId
    choiceQuery.equalTo 'card', card
    choiceQuery.find
      success: (choices) =>
        if choices?.length > 0
          return choices
        else
          return null

  getUserMood: (moodId, userId) ->
    mood = new Parse.Object 'Category'
    mood.set 'id', moodId
    user = new Parse.Object 'User'
    user.set 'id',  userId
    userMoodQuery = new Parse.Query UserMood
    userMoodQuery.include 'user'
    userMoodQuery.include 'mood'
    userMoodQuery.equalTo 'mood', mood
    userMoodQuery.equalTo 'user', user
    userMoodQuery.first
      success: (result) =>
        if result?
          user = result.get 'user'
          mood = result.get 'mood'
          return {
            firstName: user.get 'first_name'
            name: mood.get 'name'
            pic: mood.get 'iconUrl'
          }
        else
          return null

  getActivity: (userId, page, cb) ->
    activities = []
    # TODO: implement pagination
    user = new Parse.Object 'User'
    user.set 'id', userId
    activityQuery = new Parse.Query Activity
    activityQuery.include 'card'
    activityQuery.include 'user'
    activityQuery.include 'peggee'
    activityQuery.descending 'createdAt'
    # activityQuery.notEqualTo 'user', user
    activityQuery.find
      success: (results) =>
        for activity in results
          activities.push {
            message: activity.get 'message'
            pic: activity.get 'pic'
            userId: activity.get('user').id
            cardId: activity.get('card')?.id
            peggeeId: activity.get('peggee')?.id
          }
        if results.length
          #console.log @_activity
          cb activities
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        cb null

  getPeggsByUser: (userId, page, cb) ->
    peggs = []
    # todo: implement pagination
    user = new parse.object 'user'
    user.set 'id', userid
    peggquery = new parse.query pegg
    peggquery.include 'card'
    peggquery.include 'guess'
    peggquery.include 'peggee'
    peggquery.include 'user'
    peggquery.notequalto 'user', user
    peggquery.find
      success: (results) =>
        for pegg in results
          peggs.push {
            pegger: pegg.get 'user'
            peggee: pegg.get 'peggee'
            card: pegg.get 'card'
            guess: pegg.get 'guess'
          }
        if results.length
          #console.log @_activity
          cb peggs
      error: (error) ->
        console.log "Error: " + error.code + " " + error.message
        cb null

  getNewBadges: (userId, cb) ->
    user = new Parse.Object 'User'
    user.set 'id', userId
    userBadgesQuery = new Parse.Query 'UserBadges'
    userBadgesQuery.equalTo 'user', user
    userBadgesQuery.equalTo 'hasViewed', false
    userBadgesQuery.find
      success: (userBadges) ->
        userBadgesIDs = []
        for userBadge in userBadges
          userBadgesIDs.push userBadge.get('badge').id
        badgesQuery = new Parse.Query 'Badges'
        badgesQuery.containedIn 'objectId', userBadgesIDs
        badgesQuery.find
          success: (badges) =>
            if badges.length
              cb badges
            else
              cb null
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

  getTodaysMoods: ->
    catQuery = new Parse.Query Category
#    catQuery.equalTo 'type', 'mood'
    catQuery.find()

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

    if !Array.isArray cards
      for own id, card of cards
        cardObj = new Parse.Object 'Card'
        cardObj.set 'id', id
        cardObjs.push cardObj
    else
      for card in cards
        cardObj = new Parse.Object 'Card'
        cardObj.set 'id', card.cardId
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

  getPrefImages: (userId, filter, cb) ->
    user = new Parse.Object 'User'
    user.set 'id',  userId
    prefImagesQuery = new Parse.Query Pref
    prefImagesQuery.equalTo 'user', user

    # filter by recent if necessary
    if filter is 'recent'
      prefImagesQuery.addDescending 'updatedAt'

    prefImagesQuery.find
      success: (results) =>
        images = []

        # prep the data for output
        for res in results
          plug = res.get 'plug'
          card = res.get 'card'
          if plug then images.push { cardId: card.id, imageUrl: plug, userId: userId }
        
        # filter by popular if necessary
        if filter is 'popular'
          @getPrefCounts images, (counts) =>
            images.sort (a, b) ->
              counts[b.cardId].total - counts[a.cardId].total
            cb images
        else
          cb images
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null

  getProfileActivity: (userId, filter, cb) ->
    activities = []
    user = new Parse.Object 'User'
    user.set 'id',  userId
    prefQuery = new Parse.Query Pref
    prefQuery.include 'card'
    prefQuery.include 'answer'
    prefQuery.equalTo 'user', user

    # filter by recent if necessary
    if filter is 'recent'
      prefQuery.addDescending 'updatedAt'

    prefQuery.find
      success: (results) =>
        for activity in results
          card = activity.get 'card'
          activities.push {
            cardId: card.id
            userId: userId
            question: card.get 'question'
            answer: activity.get('answer').get 'text'
            plug: activity.get 'plugThumb'
            hasPegged: activity.get 'hasPegged'
          }
        if results.length
          cb activities
      error: (error) ->
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
        cb result.id
      error: (error) =>
        console.log "Error: " + error.code + " " + error.message
        cb null

  saveChoices: (cardId, answers, cb) ->
    for answer in answers
      newChoice4 = new Parse.Object 'Choice'
      newChoice4.set 'text', answer
      card = new Parse.Object 'Card'
      card.set 'id',  cardId
      newChoice4.set 'card', card
      newChoice4.save()

  saveCategories: (cardId, categories, cb) ->
    cardQuery = new Parse.Query 'Card'
    cardQuery.equalTo 'objectId', cardId
    cardQuery.first
      success: (card) =>
        for categoryName in categories
          card.addUnique 'categories', categoryName
          card.save()
        cb('catgories saved.')
      error: ->
        cb('catgories save failed.')

#      category = new Parse.Object 'Category'
#      category.set 'id',  categoryId
#      card = new Parse.Object 'Card'
#      card.set 'id',  cardId
#
#      cardCat = new Parse.Object 'CardCategory'
#      cardCat.set 'category', category
#      cardCat.set 'card', card
#      cardCat.save()
#      cb('catgories saved.')

  saveBadgeView: (badges, userId, cb) ->
    user = new Parse.Object 'User'
    user.set 'id', userId
    userBadgesQuery = new Parse.Query 'UserBadges'
    userBadgesQuery.equalTo 'user', user
    userBadgesQuery.containedIn 'badge', badges
    userBadgesQuery.find
      success: (userBadges) ->
        for userBadge in userBadges
          userBadge.set 'hasViewed', true
          userBadge.save()
        cb("#{userBadges.length} user badges saved.")
      error: ->
        cb('saving badges failed.')

parse = new ParseBackend()

module.exports = parse
