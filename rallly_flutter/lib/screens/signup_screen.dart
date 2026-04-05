import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../main.dart' show supabase;

class SignupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SignupScreen({super.key, required this.onComplete});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _pageCtrl = PageController();
  int _step = 0;

  // Step 1 data
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Step 2 data
  final _selectedSports = <String>{};

  // Step 3 data
  String? _skillLevel;

  // Step 4 data
  final _selectedDays = <String>{};
  final _selectedTimes = <String>{};

  bool _loading = false;

  static const _sports = [
    ('🎾', 'Tennis', 'Singles & doubles'),
    ('🏓', 'Padel', 'Racquet sport'),
    ('🏸', 'Badminton', 'Indoor & outdoor'),
    ('🔲', 'Squash', 'Court sport'),
  ];

  static const _skills = [
    ('🟢', 'Beginner', 'Under 1 year playing'),
    ('🟡', 'Intermediate', '1–4 years experience'),
    ('🟠', 'Advanced', 'Competitive play'),
    ('🔴', 'Expert', 'Tournament level'),
  ];

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _times = [
    ('🌅', 'Morning', '6am–12pm'),
    ('☀️', 'Afternoon', '12pm–6pm'),
    ('🌙', 'Evening', '6pm–11pm'),
  ];

  void _next() {
    if (_step < 3) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      setState(() => _step--);
    }
  }

  bool get _canProceed {
    switch (_step) {
      case 0: return _nameCtrl.text.trim().isNotEmpty && _locationCtrl.text.trim().isNotEmpty;
      case 1: return _selectedSports.isNotEmpty;
      case 2: return _skillLevel != null;
      case 3: return _selectedDays.isNotEmpty;
      default: return false;
    }
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('profiles').upsert({
          'id': userId,
          'name': _nameCtrl.text.trim(),
          'location': _locationCtrl.text.trim(),
          'sports': _selectedSports.toList(),
          'skill_level': _skillLevel,
          'available_days': _selectedDays.toList(),
          'time_prefs': _selectedTimes.toList(),
        });
      }
    } catch (_) {
      // Continue even if profile save fails — user can update later
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        widget.onComplete();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: _back,
                      padding: EdgeInsets.zero,
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rall',
                          style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22, color: RallyColors.accent),
                        ),
                        TextSpan(
                          text: 'l',
                          style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22, color: RallyColors.textPrimary, fontStyle: FontStyle.italic),
                        ),
                        TextSpan(
                          text: 'y',
                          style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22, color: RallyColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_step + 1}/4',
                    style: const TextStyle(fontSize: 13, color: RallyColors.muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            // ── Progress bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: List.generate(4, (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: i <= _step ? RallyColors.accent : RallyColors.border2,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            // ── Pages ─────────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1(nameCtrl: _nameCtrl, locationCtrl: _locationCtrl, onChanged: () => setState(() {})),
                  _Step2(selected: _selectedSports, onChanged: () => setState(() {})),
                  _Step3(selected: _skillLevel, onSelect: (v) => setState(() => _skillLevel = v)),
                  _Step4(selectedDays: _selectedDays, selectedTimes: _selectedTimes, onChanged: () => setState(() {})),
                ],
              ),
            ),

            // ── CTA ────────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: RallyButton(
                label: _step == 3 ? 'Finish — Let\'s play 🎾' : 'Continue',
                onPressed: _canProceed ? _next : null,
                loading: _loading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1: Basic info ───────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;
  final VoidCallback onChanged;

  const _Step1({required this.nameCtrl, required this.locationCtrl, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          const Text(
            'Help players find and connect with you',
            style: TextStyle(color: RallyColors.textSecondary, fontSize: 15, height: 1.5),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: nameCtrl,
            onChanged: (_) => onChanged(),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'FULL NAME',
              hintText: 'e.g. Alex Wilson',
              prefixIcon: Icon(Icons.person_outline, size: 18),
            ),
          ).animate().fadeIn(delay: 120.ms),
          const SizedBox(height: 16),
          TextFormField(
            controller: locationCtrl,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              labelText: 'NEIGHBOURHOOD / CITY',
              hintText: 'e.g. Islington, London',
              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
            ),
          ).animate().fadeIn(delay: 160.ms),
        ],
      ),
    );
  }
}

// ─── Step 2: Sports selection ─────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final Set<String> selected;
  final VoidCallback onChanged;

  const _Step2({required this.selected, required this.onChanged});

  static const _sports = [
    ('🎾', 'Tennis', 'Singles & doubles'),
    ('🏓', 'Padel', 'Racquet sport'),
    ('🏸', 'Badminton', 'Indoor & outdoor'),
    ('🔲', 'Squash', 'Court sport'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which sports do you play?',
            style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Select all that apply',
            style: TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: _sports.map((s) {
              final isSelected = selected.contains(s.$2);
              return GestureDetector(
                onTap: () {
                  if (isSelected) {
                    selected.remove(s.$2);
                  } else {
                    selected.add(s.$2);
                  }
                  onChanged();
                },
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? RallyColors.accentLight : RallyColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? RallyColors.accent : RallyColors.border2,
                      width: 1.5,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: const TextStyle(fontSize: 28)),
                      const Spacer(),
                      Text(s.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(s.$3, style: const TextStyle(fontSize: 11, color: RallyColors.muted)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 120.ms),
        ],
      ),
    );
  }
}

// ─── Step 3: Skill level ──────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;

  const _Step3({required this.selected, required this.onSelect});

  static const _skills = [
    ('🟢', 'Beginner', 'Under 1 year — learning the basics'),
    ('🟡', 'Intermediate', '1–4 years — comfortable rallying'),
    ('🟠', 'Advanced', 'Competitive — strong all-round game'),
    ('🔴', 'Expert', 'Tournament-level — top of the game'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your skill level?',
            style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Be honest — it helps find the best matches',
            style: TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),
          ...List.generate(_skills.length, (i) {
            final skill = _skills[i];
            final isSelected = selected == skill.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onSelect(skill.$2),
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? RallyColors.accentLight : RallyColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? RallyColors.accent : RallyColors.border2,
                      width: 1.5,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? RallyColors.accent.withValues(alpha: 0.1) : RallyColors.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Center(child: Text(skill.$1, style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(skill.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text(skill.$3, style: const TextStyle(fontSize: 12, color: RallyColors.muted)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: RallyColors.accent, size: 22),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (i * 60 + 100).ms).slideX(begin: 0.05, end: 0),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Step 4: Availability ─────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final Set<String> selectedDays;
  final Set<String> selectedTimes;
  final VoidCallback onChanged;

  const _Step4({required this.selectedDays, required this.selectedTimes, required this.onChanged});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _times = [
    ('🌅', 'Morning', '6am–12pm'),
    ('☀️', 'Afternoon', '12pm–6pm'),
    ('🌙', 'Evening', '6pm–11pm'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'When are you usually free?',
            style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          const Text(
            'Select your typical availability',
            style: TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),

          // Days grid
          const Text('DAYS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: _days.map((d) {
              final isSelected = selectedDays.contains(d);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      selectedDays.remove(d);
                    } else {
                      selectedDays.add(d);
                    }
                    onChanged();
                  },
                  child: AnimatedContainer(
                    duration: 160.ms,
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? RallyColors.accent : RallyColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? RallyColors.accent : RallyColors.border2,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          d.substring(0, 1),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white70 : RallyColors.muted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          d.substring(1),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : RallyColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 120.ms),

          const SizedBox(height: 24),

          // Time preference
          const Text('TIME OF DAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: _times.map((t) {
              final isSelected = selectedTimes.contains(t.$2);
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      selectedTimes.remove(t.$2);
                    } else {
                      selectedTimes.add(t.$2);
                    }
                    onChanged();
                  },
                  child: AnimatedContainer(
                    duration: 160.ms,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? RallyColors.accentLight : RallyColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? RallyColors.accent : RallyColors.border2,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          t.$2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? RallyColors.accent : RallyColors.textPrimary,
                          ),
                        ),
                        Text(t.$3, style: const TextStyle(fontSize: 10, color: RallyColors.muted)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 160.ms),
        ],
      ),
    );
  }
}
