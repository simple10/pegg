config =
  game_flows:
    default: [
      [      # stage 1
        {
          type: 'pref'
          size: 3
        }
        {
          type: 'message_next_friend'
          # Now you’re gonna play about your friend: FriendA
        }
      ]
      [      # stage 2
        {
          type: 'pegg'
          size: 3
        }
        {
          type: 'status_friend_ranking'
          # How do I compare to his friends?
        }
      ]
    ]

  scripts:
    cosmic_unicorn:
      fail: [
        'Almost... but not quite.<br/>Try again.'
        'You\'re awesome!<br/>But that guess wasn\'t.'
        'Don\'t worry,<br/>that fail is safe with us.'
        'Hmm... try again.<br/>You got this.'
      ]
      win: [
        'Hooray!! You rule!'
        'Crushin\' it!'
        'Way to be a decent friend.'
        'Friend points earned!'
        'Dude!<br/>Way to not suck at this.'
      ]
      pref: [
        'Preference saved.'
        'So that\'s what you\'re into.<br/>Interesting...'
        'Noted. Carry on.'
        'Your friends will be relieved.'
        'Confucius say:<br/>preferences are like buttholes.'
      ]
      misc: [
        ''
      ]

module.exports = config
