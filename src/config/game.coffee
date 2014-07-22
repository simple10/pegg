config =
  game_flows:
    default: [
      [      # stage 1
        {
          # type: 'pref'
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
        'Wow. <br/>I\'m learning so much<br/>about you.'
        'So that\'s what you\'re into.<br/>Interesting...'
        'Noted. Carry on.'
        'Your friends will be <br/>relieved to know that.'
        'Confucius say:<br/>preferences are like<br/>buttholes.'
      ]
      misc: [
        ''
      ]

module.exports = config
