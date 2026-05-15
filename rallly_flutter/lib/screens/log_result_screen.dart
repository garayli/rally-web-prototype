import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show supabase;
import 'result_card_screen.dart';

class LogResultScreen extends StatefulWidget {
  final Player? opponent;
  const LogResultScreen({super.key, this.opponent});

  @override
  State<LogResultScreen> createState() => _LogResultScreenState();
}

class _LogResultScreenState extends State<LogResultScreen> {
  Player? _opponent;
  bool _guestMode = false;
  final _guestNameCtrl = TextEditingController();
  final _guestPhoneCtrl = TextEditingController();

  // Set scores: [p1, p2] for each set
  final _s1 = [TextEditingController(), TextEditingController()];
  final _s2 = [TextEditingController(), TextEditingController()];
  final _s3 = [TextEditingController(), TextEditingController()];
  bool _showSet3 = false;

  String? _winner;  // 'me' or 'opponent'
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _opponent = widget.opponent ?? dataService.getPlayers().first;
    for (final c in [..._s1, ..._s2, ..._s3]) {
      c.addListener(_autoDetectWinner);
    }
  }

  void _autoDetectWinner() {
    final s1me = int.tryParse(_s1[0].text) ?? 0;
    final s1op = int.tryParse(_s1[1].text) ?? 0;
    final s2me = int.tryParse(_s2[0].text) ?? 0;
    final s2op = int.tryParse(_s2[1].text) ?? 0;
    int meSets = 0, opSets = 0;
    if (s1me > s1op) meSets++; else if (s1op > s1me) opSets++;
    if (s2me > s2op) meSets++; else if (s2op > s2me) opSets++;
    if (_showSet3) {
      final s3me = int.tryParse(_s3[0].text) ?? 0;
      final s3op = int.tryParse(_s3[1].text) ?? 0;
      if (s3me > s3op) meSets++; else if (s3op > s3me) opSets++;
    }
    String? newWinner;
    if (meSets > opSets) newWinner = 'me';
    else if (opSets > meSets) newWinner = 'opponent';
    setState(() => _winner = newWinner);
  }

  bool get _canSubmit {
    if (_guestMode && _guestPhoneCtrl.text.trim().length < 10) return false;
    if (!_guestMode && _opponent == null) return false;
    final s1Valid = _s1[0].text.isNotEmpty && _s1[1].text.isNotEmpty;
    final s2Valid = _s2[0].text.isNotEmpty && _s2[1].text.isNotEmpty;
    if (!s1Valid || !s2Valid) return false;
    if (_showSet3 && (_s3[0].text.isEmpty || _s3[1].text.isEmpty)) return false;
    return true;
  }

  Future<void> _submit() async {
    if (!_canSubmit || _winner == null || _loading) return;
    setState(() => _loading = true);
    final effectiveOpponent = _guestMode ? _guestPlayer() : _opponent!;
    final sets = <SetScore>[
      SetScore(int.tryParse(_s1[0].text) ?? 0, int.tryParse(_s1[1].text) ?? 0),
      SetScore(int.tryParse(_s2[0].text) ?? 0, int.tryParse(_s2[1].text) ?? 0),
      if (_showSet3 && _s3[0].text.isNotEmpty)
        SetScore(int.tryParse(_s3[0].text) ?? 0, int.tryParse(_s3[1].text) ?? 0),
    ];
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        if (!mounted) return;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Oturum açmanız gerekiyor'),
          backgroundColor: RallyColors.accent2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
        return;
      }
      await supabase.from('matches').insert({
        'player1_id': userId,
        'player2_id': _guestMode ? null : effectiveOpponent.id,
        'status': 'completed',
        'format': 'singles',
        'date_time': DateTime.now().toUtc().toIso8601String(),
        'court': 'Belirtilmedi',
        'winner_id': _winner == 'me' ? userId : null,
        'sets': sets.map((s) => s.toJson()).toList(),
        'rating_delta': _winner == 'me' ? 12.0 : -8.0,
        // only sent for unregistered opponents — columns must exist in DB
        if (_guestMode) ...{
          'opponent_name': effectiveOpponent.name,
          'opponent_phone': _guestPhoneCtrl.text.trim(),
        },
      });
    } catch (e, st) {
      debugPrint('FULL ERROR: ${e.runtimeType}: $e');
      debugPrint('LOG RESULT ERROR: $e\n$st');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Sonuç kaydedilemedi: $e'),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    if (!mounted) return;
    final result = MatchResult(
      winnerId: _winner == 'me' ? 'me' : effectiveOpponent.id,
      sets: sets,
      ratingDelta: _winner == 'me' ? 12 : -8,
    );
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => ResultCardScreen(opponent: effectiveOpponent, result: result),
    ));
  }

  Player _guestPlayer() {
    final name = _guestNameCtrl.text.trim().isNotEmpty
        ? _guestNameCtrl.text.trim()
        : _guestPhoneCtrl.text.trim();
    final initials = name.split(' ').take(2)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
    return Player(id: 'guest', name: name, initials: initials, ntrpRating: 3.0, location: '');
  }

  @override
  void dispose() {
    _guestNameCtrl.dispose();
    _guestPhoneCtrl.dispose();
    for (final c in [..._s1, ..._s2, ..._s3]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('Sonuç Kaydet', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opponent selector
            const _SLabel('RAKİP'),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dataService.getPlayers().length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  // Last item: guest chip
                  if (i == dataService.getPlayers().length) {
                    return GestureDetector(
                      onTap: () => setState(() { _guestMode = true; _opponent = null; }),
                      child: AnimatedContainer(
                        duration: 160.ms,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _guestMode ? RallyColors.accent : RallyColors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: _guestMode ? RallyColors.accent : RallyColors.border2, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person_add_outlined, size: 15,
                                color: _guestMode ? Colors.white : RallyColors.accent),
                            const SizedBox(width: 6),
                            Text('Kayıtsız Oyuncu',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                    color: _guestMode ? Colors.white : RallyColors.textPrimary)),
                          ],
                        ),
                      ),
                    );
                  }
                  final p = dataService.getPlayers()[i];
                  final sel = !_guestMode && _opponent?.id == p.id;
                  return GestureDetector(
                    onTap: () => setState(() { _guestMode = false; _opponent = p; }),
                    child: AnimatedContainer(
                      duration: 160.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? RallyColors.accent : RallyColors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: sel ? RallyColors.accent : RallyColors.border2, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          PlayerAvatar(
                            initials: p.initials,
                            gradientStart: p.avatarGradientStart,
                            gradientEnd: p.avatarGradientEnd,
                            size: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p.name.split(' ').first,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : RallyColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 80.ms),

            if (_guestMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _guestPhoneCtrl,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: const InputDecoration(
                  hintText: 'Telefon numarası (zorunlu)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _guestNameCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'İsim (opsiyonel)',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
            ],

            const SizedBox(height: 28),

            // Score entry
            _ScoreHeader(
              myLabel: 'Sen',
              opponentLabel: _guestMode
                  ? (_guestNameCtrl.text.trim().isNotEmpty
                      ? _guestNameCtrl.text.trim().split(' ').first
                      : 'Rakip')
                  : (_opponent?.name.split(' ').first ?? 'Rakip'),
            ),
            const SizedBox(height: 12),
            _SetRow(label: 'SET 1', controllers: _s1).animate().fadeIn(delay: 120.ms),
            const SizedBox(height: 10),
            _SetRow(label: 'SET 2', controllers: _s2).animate().fadeIn(delay: 140.ms),
            if (_showSet3) ...[
              const SizedBox(height: 10),
              _SetRow(label: 'SET 3', controllers: _s3).animate().fadeIn(),
            ],

            if (!_showSet3) ...[
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => setState(() => _showSet3 = true),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: RallyColors.accent),
                    SizedBox(width: 6),
                    Text('3. seti ekle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: RallyColors.accent)),
                  ],
                ),
              ),
            ],

            // Winner selector
            if (_winner == null && _canSubmit) ...[
              const SizedBox(height: 24),
              const _SLabel('KAZANAN'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _winner = 'me'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _winner == 'me' ? RallyColors.accentLight : RallyColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _winner == 'me' ? RallyColors.accent : RallyColors.border2, width: 1.5),
                        ),
                        child: Center(child: Text('Ben kazandım 🏆', style: TextStyle(fontWeight: FontWeight.w700, color: _winner == 'me' ? RallyColors.accent : RallyColors.textPrimary))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _winner = 'opponent'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _winner == 'opponent' ? RallyColors.accent2Light : RallyColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _winner == 'opponent' ? RallyColors.accent2 : RallyColors.border2, width: 1.5),
                        ),
                        child: Center(child: Text('Rakip kazandı', style: TextStyle(fontWeight: FontWeight.w700, color: _winner == 'opponent' ? RallyColors.accent2 : RallyColors.textPrimary))),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_winner != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _winner == 'me' ? RallyColors.accentLight : RallyColors.accent2Light,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _winner == 'me' ? RallyColors.accent : RallyColors.accent2),
                ),
                child: Row(
                  children: [
                    Icon(_winner == 'me' ? Icons.emoji_events : Icons.sentiment_neutral,
                        color: _winner == 'me' ? RallyColors.accent : RallyColors.accent2),
                    const SizedBox(width: 10),
                    Text(
                      _winner == 'me'
                          ? 'Bu maçı kazandınız!'
                          : '${(_guestMode ? _guestNameCtrl.text.trim().split(' ').firstOrNull : _opponent?.name.split(' ').first) ?? 'Rakip'} kazandı',
                      style: TextStyle(fontWeight: FontWeight.w700, color: _winner == 'me' ? RallyColors.accent : RallyColors.accent2),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _winner = null),
                      child: const Text('Değiştir', style: TextStyle(fontSize: 12, color: RallyColors.muted)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            RallyButton(
              label: 'Sonucu Kaydet',
              onPressed: (_canSubmit && _winner != null) ? _submit : null,
              loading: _loading,
              icon: Icons.check,
            ).animate().fadeIn(delay: 160.ms),
          ],
        ),
      ),
    );
  }
}

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
  );
}

class _ScoreHeader extends StatelessWidget {
  final String myLabel;
  final String opponentLabel;
  const _ScoreHeader({required this.myLabel, required this.opponentLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 60),
        const SizedBox(width: 14),
        Expanded(child: Center(child: Text(myLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1))),
        const SizedBox(width: 10),
        Expanded(child: Center(child: Text(opponentLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: RallyColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 1))),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  final String label;
  final List<TextEditingController> controllers;

  const _SetRow({required this.label, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: RallyColors.muted)),
        ),
        const SizedBox(width: 14),
        Expanded(child: _ScoreInput(controller: controllers[0])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('–', style: TextStyle(fontWeight: FontWeight.w700, color: RallyColors.muted)),
        ),
        Expanded(child: _ScoreInput(controller: controllers[1])),
      ],
    );
  }
}

class _ScoreInput extends StatelessWidget {
  final TextEditingController controller;
  const _ScoreInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
      style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 24, letterSpacing: -0.5),
      decoration: const InputDecoration(
        hintText: '0',
        contentPadding: EdgeInsets.symmetric(vertical: 12),
        hintStyle: TextStyle(color: RallyColors.muted2, fontFamily: 'InstrumentSerif', fontSize: 24),
      ),
    );
  }
}
