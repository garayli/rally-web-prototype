import '../models/models.dart';

// ─── Mock data ────────────────────────────────────────────────────────────────
// Do not call MockData directly from screens — use dataService (data_service.dart).
// senderId: 'me' is a sentinel for the current user. When Supabase is wired,
// replace with supabase.auth.currentUser!.id everywhere.
class MockData {
  MockData._();

  static final List<Player> players = [
    const Player(
      id: '1',
      name: 'Zeynep Arslan',
      initials: 'ZA',
      ntrpRating: 4.0,
      location: 'Beşiktaş · 0.4 km',
      about: 'Competitive player with 8 years experience. Love baseline rallies '
          'and serve-and-volley. Available weekday evenings and weekends.',
      wins: 24,
      losses: 8,
      matchesPlayed: 32,
      winRate: 75,
      matchScore: 94,
      availability: ['Pzt ÖÖ', 'Sal ÖS', 'Çar ÖS', 'Cmt Tam', 'Paz Tam'],
      preferredCourts: ['Beşiktaş JK Tenis Kortları', 'Levent Tenis Kulübü'],
      avatarGradientStart: '#5a8a00',
      avatarGradientEnd: '#8db600',
    ),
    const Player(
      id: '2',
      name: 'Emre Kaya',
      initials: 'EK',
      ntrpRating: 3.5,
      location: 'Kadıköy · 1.2 km',
      about: 'Casual competitive player. Strong forehand, working on my backhand. '
          'Always up for a tough match and a post-game tea.',
      wins: 18,
      losses: 14,
      matchesPlayed: 32,
      winRate: 56,
      matchScore: 87,
      availability: ['Çar ÖÖ', 'Per ÖS', 'Cum ÖS', 'Cmt ÖÖ'],
      preferredCourts: ['Caddebostan Tenis Kortları', 'Fenerbahçe SK Tenis Kortları'],
      avatarGradientStart: '#e85d3a',
      avatarGradientEnd: '#f4956d',
    ),
    const Player(
      id: '3',
      name: 'Selin Demir',
      initials: 'SD',
      ntrpRating: 4.5,
      location: 'Şişli · 2.1 km',
      about: 'Former regional champion returning to competitive tennis. Big serve, '
          'net game specialist. Looking for challenging matches.',
      wins: 41,
      losses: 11,
      matchesPlayed: 52,
      winRate: 79,
      matchScore: 82,
      availability: ['Pzt Tam', 'Sal Tam', 'Per ÖÖ', 'Paz ÖS'],
      preferredCourts: ['Galatasaray Tenis Kulübü', 'ENKA Spor Kortları'],
      avatarGradientStart: '#7b4fa6',
      avatarGradientEnd: '#a97fcb',
    ),
    const Player(
      id: '4',
      name: 'Berk Öztürk',
      initials: 'BÖ',
      ntrpRating: 3.0,
      location: 'Üsküdar · 1.8 km',
      about: 'Beginner-to-intermediate. Keen to improve and meet other players. '
          'Prefer relaxed but competitive games.',
      wins: 7,
      losses: 13,
      matchesPlayed: 20,
      winRate: 35,
      matchScore: 76,
      availability: ['Sal ÖÖ', 'Cmt ÖS', 'Paz ÖÖ'],
      preferredCourts: ['Acıbadem Tenis Kulübü', 'Üsküdar Spor Kompleksi'],
      avatarGradientStart: '#1a7abf',
      avatarGradientEnd: '#5ba8e0',
    ),
  ];

  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      type: NotifType.matchRequest,
      title: 'Maç İsteği',
      body: 'Emre Kaya Cumartesi saat 10:00\'da oynamak istiyor · Caddebostan Tenis Kortları',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      isRead: false,
      avatarInitials: 'EK',
      avatarColor: '#e85d3a',
      actionId: 'match_1',
    ),
    AppNotification(
      id: 'n2',
      type: NotifType.resultConfirmed,
      title: 'Maç Sonucu Onaylandı',
      body: 'Zeynep Arslan 6-4, 7-5 galibiyetinizi onayladı. +12 puan 🎾',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      avatarInitials: 'ZA',
      avatarColor: '#5a8a00',
      actionId: 'match_2',
    ),
    AppNotification(
      id: 'n3',
      type: NotifType.review,
      title: 'Yeni Değerlendirme',
      body: 'Selin Demir sizi değerlendirdi: "Harika ralliler, çok sportif — rövanş bekliyorum!"',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      avatarInitials: 'SD',
      avatarColor: '#7b4fa6',
    ),
    AppNotification(
      id: 'n4',
      type: NotifType.reminder,
      title: 'Yarın Maç Var',
      body: 'Hatırlatma: Emre Kaya · 10:00 · Caddebostan Tenis Kortları. Detaylar için tıklayın.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      avatarInitials: 'EK',
      avatarColor: '#e85d3a',
    ),
    AppNotification(
      id: 'n5',
      type: NotifType.matchConfirmed,
      title: 'Maç Onaylandı ✓',
      body: 'Zeynep Arslan maç isteğinizi kabul etti. Perşembe 19:00\'da Beşiktaş JK Tenis Kortları.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      isRead: true,
      avatarInitials: 'ZA',
      avatarColor: '#5a8a00',
    ),
    AppNotification(
      id: 'n6',
      type: NotifType.cancellation,
      title: 'Maç İptal Edildi',
      body: 'Berk Öztürk Cumartesi maçını iptal etti. Aşağıdan yeni rakip bulabilirsiniz.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      avatarInitials: 'BÖ',
      avatarColor: '#1a7abf',
    ),
    AppNotification(
      id: 'n7',
      type: NotifType.nearbyPlayer,
      title: 'Yakında Yeni Oyuncular',
      body: 'Bu hafta Beşiktaş\'ta seviyenize uygun 3 yeni oyuncu katıldı. Hemen inceleyin!',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      avatarInitials: '🎾',
      avatarColor: '#5a8a00',
    ),
  ];

  static final List<MatchSession> upcomingSessions = [
    MatchSession(
      id: 'm1',
      opponent: players[1],   // Emre
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      court: 'Caddebostan Tenis Kortları',
      status: MatchStatus.confirmed,
    ),
    MatchSession(
      id: 'm2',
      opponent: players[0],   // Zeynep
      dateTime: DateTime.now().add(const Duration(days: 3, hours: 19)),
      court: 'Beşiktaş JK Tenis Kortları',
      status: MatchStatus.pending,
    ),
  ];

  static final List<Conversation> conversations = [
    Conversation(
      id: 'c1',
      other: players[0],  // Zeynep
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'msg1',
          senderId: '1',
          text: 'Merhaba! Perşembe maçımız için sabırsızlanıyorum 🎾',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          isRead: false,
        ),
        ChatMessage(
          id: 'msg2',
          senderId: 'me', // sentinel: current user (not a player ID)
          text: 'Ben de! Saat 19:00\'da 3. kort?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: true,
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      other: players[1],  // Emre
      isOnline: false,
      messages: [
        ChatMessage(
          id: 'msg3',
          senderId: 'me', // sentinel: current user (not a player ID)
          text: 'Dün güzel maçtı! Haftaya rövanş?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isRead: true,
        ),
      ],
    ),
    Conversation(
      id: 'c3',
      other: players[2],  // Selin
      isOnline: true,
      messages: [
        ChatMessage(
          id: 'msg4',
          senderId: '3',
          text: 'Pazar sabahı müsait misin? Galatasaray kortları boş olacak.',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          isRead: false,
        ),
      ],
    ),
  ];
}
