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
          type: 'profile_progress'
          # How am I doing about myself?
        }
      ]
      [      # stage 2
        {
          type: 'pegg'
          size: 3
        }
        {
          type: 'friend_ranking'
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
        'Time to learn about you!'
        'Go on...<br/>Pegg yourself.'
        'Dig deep and uncover your true self.'
        'Know thyself, <br/>grasshopper.'
        'Pegg yourself.'
      ]
      pegg: [
        'Pegg your friend.'
        'What did your friend choose?'
        'This isn\'t all about you.'
        'Can you pegg your friend?'
      ]

module.exports = config
