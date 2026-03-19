import '../models/models.dart';

// ─── Mock data (replace with real Supabase calls) ────────────────────────────
class MockData {
  MockData._();

  static final List<Player> players = [
    const Player(
      id: '1',
      name: 'Priya Sharma',
      initials: 'PS',
      ntrpRating: 4.0,
      location: 'Islington · 0.4 mi',
      about: 'Competitive player with 8 years experience. Love baseline rallies '
          'and serve-and-volley. Available weekday evenings and weekends.',
      wins: 24,
      losses: 8,
      matchesPlayed: 32,
      winRate: 75,
      matchScore: 94,
      availability: ['Mon AM', 'Tue PM', 'Wed PM', 'Sat Full', 'Sun Full'],
      preferredCourts: ['Highbury Fields', 'Islington Tennis Centre'],
      avatarGradientStart: '#5a8a00',
      avatarGradientEnd: '#8db600',
    ),
    const Player(
      id: '2',
      name: 'Marcus Osei',
      initials: 'MO',
      ntrpRating: 3.5,
      location: 'Hackney · 1.2 mi',
      about: 'Casual competitive player. Strong forehand, working on my backhand. '
          'Always up for a tough match and a post-game coffee.',
      wins: 18,
      losses: 14,
      matchesPlayed: 32,
      winRate: 56,
      matchScore: 87,
      availability: ['Wed AM', 'Thu PM', 'Fri PM', 'Sat AM'],
      preferredCourts: ['London Fields', 'Victoria Park'],
      avatarGradientStart: '#e85d3a',
      avatarGradientEnd: '#f4956d',
    ),
    const Player(
      id: '3',
      name: 'Sophie Chen',
      initials: 'SC',
      ntrpRating: 4.5,
      location: 'Camden · 2.1 mi',
      about: 'Former county player returning to competitive tennis. Big serve, '
          'net game specialist. Looking for challenging matches.',
      wins: 41,
      losses: 11,
      matchesPlayed: 52,
      winRate: 79,
      matchScore: 82,
      availability: ['Mon Full', 'Tue Full', 'Thu AM', 'Sun PM'],
      preferredCourts: ['Regent\'s Park', 'Parliament Hill'],
      avatarGradientStart: '#7b4fa6',
      avatarGradientEnd: '#a97fcb',
    ),
    const Player(
      id: '4',
      name: 'James Whitfield',
      initials: 'JW',
      ntrpRating: 3.0,
      location: 'Shoreditch · 1.8 mi',
      about: 'Beginner-to-intermediate. Keen to improve and meet other players. '
          'Prefer relaxed but competitive games.',
      wins: 7,
      losses: 13,
      matchesPlayed: 20,
      winRate: 35,
      matchScore: 76,
      availability: ['Tue AM', 'Sat PM', 'Sun AM'],
      preferredCourts: ['Shoreditch Park', 'Haggerston Park'],
      avatarGradientStart: '#1a7abf',
      avatarGradientEnd: '#5ba8e0',
    ),
  ];

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      type: NotifType.matchRequest,
      title: 'Match Request',
      body: 'Marcus Osei wants to play on Saturday at 10:00am · London Fields',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
      avatarInitials: 'MO',
      avatarColor: '#e85d3a',
      actionId: 'match_1',
    ),
    AppNotification(
      id: 'n2',
      type: NotifType.resultConfirmed,
      title: 'Match Result Confirmed',
      body: 'Priya Sharma confirmed your 6-4, 7-5 win. +12 rating points 🎾',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      avatarInitials: 'PS',
      avatarColor: '#5a8a00',
      actionId: 'match_2',
    ),
    AppNotification(
      id: 'n3',
      type: NotifType.review,
      title: 'New Review',
      body: 'Sophie Chen left you a review: "Great rallies, very sporting — looking forward to a rematch!"',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      avatarInitials: 'SC',
      avatarColor: '#7b4fa6',
    ),
    AppNotification(
      id: 'n4',
      type: NotifType.reminder,
      title: 'Match Tomorrow',
      body: 'Reminder: Marcus Osei · 10:00am · London Fields Courts. Tap to view details.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      avatarInitials: 'MO',
      avatarColor: '#e85d3a',
    ),
    AppNotification(
      id: 'n5',
      type: NotifType.matchConfirmed,
      title: 'Match Confirmed ✓',
      body: 'Priya Sharma accepted your match request. Thursday 7:00pm at Highbury Fields.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isRead: true,
      avatarInitials: 'PS',
      avatarColor: '#5a8a00',
    ),
    AppNotification(
      id: 'n6',
      type: NotifType.cancellation,
      title: 'Match Cancelled',
      body: 'James Whitfield cancelled Saturday\'s match. You can find a new opponent below.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      avatarInitials: 'JW',
      avatarColor: '#1a7abf',
    ),
    AppNotification(
      id: 'n7',
      type: NotifType.nearbyPlayer,
      title: 'New Player Nearby',
      body: '3 new players joined in Islington this week matching your skill level. Check them out!',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      avatarInitials: '🎾',
      avatarColor: '#5a8a00',
    ),
  ];

  static final List<MatchSession> upcomingSessions = [
    MatchSession(
      id: 'm1',
      opponent: players[1],   // Marcus
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      court: 'London Fields',
      status: MatchStatus.confirmed,
    ),
    MatchSession(
      id: 'm2',
      opponent: players[0],   // Priya
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 19)),
      court: 'Highbury Fields',
      status: MatchStatus.pending,
    ),
  ];

  static final List<Conversation> conversations = [
    Conversation(
      id: 'c1',
      other: players[0],  // Priya
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'msg1',
          senderId: '1',
          text: 'Hey! Looking forward to our match on Thursday 🎾',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        ChatMessage(
          id: 'msg2',
          senderId: 'me',
          text: 'Same here! Court 3 at 7pm?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: true,
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      other: players[1],  // Marcus
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'msg3',
          senderId: 'me',
          text: 'Good game yesterday! Rematch next week?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      other: players[2],  // Sophie
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'msg4',
          senderId: '3',
          text: 'Are you free Sunday morning? Regent\'s Park has open courts',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isRead: false,
        ),
      ],
    ),
  ];
}
