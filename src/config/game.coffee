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

  unicorns:
    becca:
      correct: [
        ''
      ]
      incorrect: [
        ''
      ]
      misc: [
        ''
      ]

module.exports = config
