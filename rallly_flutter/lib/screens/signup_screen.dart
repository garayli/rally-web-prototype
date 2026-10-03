import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/profile_options.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../main.dart' show supabase;
import '../utils/initials.dart';
import '../l10n/l10n.dart';
import '../l10n/option_labels.dart';

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

  /// "Ad Soyad" needs both words — a lone first name was being followed by a
  /// surname typed into the location field below it.
  bool get _hasFullName =>
      _nameCtrl.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length >= 2;

  bool get _canProceed {
    switch (_step) {
      case 0: return _hasFullName && _locationCtrl.text.trim().isNotEmpty;
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
      if (userId == null) throw StateError('no signed-in user');
      await supabase.from('profiles').upsert({
        'id': userId,
        'name': _nameCtrl.text.trim(),
        // NOT NULL in `profiles` — omitting it failed every new signup.
        'initials': initialsOf(_nameCtrl.text),
        'location': _locationCtrl.text.trim(),
        'sports': _selectedSports.toList(),
        'skill_level': _skillLevel,
        if (_skillLevel != null) 'ntrp_rating': ntrpBySkillLevel[_skillLevel],
        'available_days': _selectedDays.toList(),
        'time_prefs': _selectedTimes.toList(),
      });
      if (mounted) widget.onComplete();
    } catch (e) {
      // Stay on the wizard: moving on after a failed save is what made
      // profiles "disappear" and forced a re-signup on every login.
      debugPrint('SIGNUP PROFILE SAVE ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.signupSaveFailed),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
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
                label: _step == 3
                    ? context.l10n.signupFinish
                    : context.l10n.signupContinue,
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
          Text(
            context.l10n.signupStep1Title,
            style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            context.l10n.signupStep1Subtitle,
            style: const TextStyle(color: RallyColors.textSecondary, fontSize: 15, height: 1.5),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: nameCtrl,
            onChanged: (_) => onChanged(),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: context.l10n.signupNameLabel,
              hintText: context.l10n.signupNameHint,
              prefixIcon: const Icon(Icons.person_outline, size: 18),
            ),
          ).animate().fadeIn(delay: 120.ms),
          const SizedBox(height: 16),
          TextFormField(
            controller: locationCtrl,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              labelText: context.l10n.signupLocationLabel,
              hintText: context.l10n.signupLocationHint,
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.signupStep2Title,
            style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            context.l10n.signupStep2Subtitle,
            style: const TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.35,
            children: sportOptions.map((s) {
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
                      Text(sportLabel(context.l10n, s.$2), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(sportSubtitle(context.l10n, s.$2), style: const TextStyle(fontSize: 11, color: RallyColors.muted)),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.signupStep3Title,
            style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            context.l10n.signupStep3Subtitle,
            style: const TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),
          ...List.generate(skillOptions.length, (i) {
            final skill = skillOptions[i];
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
                            Text(skillLevelLabel(context.l10n, skill.$2), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            Text(skillSubtitle(context.l10n, skill.$2), style: const TextStyle(fontSize: 12, color: RallyColors.muted)),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.signupStep4Title,
            style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 32, letterSpacing: -1.5, height: 1.1),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            context.l10n.signupStep4Subtitle,
            style: const TextStyle(color: RallyColors.textSecondary, fontSize: 15),
          ).animate().fadeIn(delay: 80.ms),
          const SizedBox(height: 28),

          // Days grid
          Text(context.l10n.signupDaysHeader, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: dayOptions.map((d) {
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
                          dayLabel(context.l10n, d).substring(0, 1),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white70 : RallyColors.muted,
                            letterSpacing: 0.3,
                          ),
                        ),
                        Text(
                          dayLabel(context.l10n, d).substring(1),
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
          Text(context.l10n.signupTimeOfDayHeader, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: timeOptions.map((t) {
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
                          timeLabel(context.l10n, t.$2),
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
