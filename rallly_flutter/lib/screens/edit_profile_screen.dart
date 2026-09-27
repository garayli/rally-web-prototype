import 'package:flutter/material.dart';
import '../config/profile_options.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../main.dart' show CourtThemeProvider;

/// Lets the signed-in user change everything they entered in the signup
/// wizard (plus a bio). Pops `true` after a successful save.
class EditProfileScreen extends StatefulWidget {
  final Player player;
  const EditProfileScreen({super.key, required this.player});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final _nameCtrl = TextEditingController(text: widget.player.name);
  late final _locationCtrl = TextEditingController(text: widget.player.location);
  late final _aboutCtrl = TextEditingController(text: widget.player.about);
  late final _sports = {...widget.player.sports};
  late String? _skillLevel = widget.player.skillLevel;
  late final _days = {...widget.player.availableDays};
  late final _times = {...widget.player.timePrefs};
  bool _saving = false;

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty && _locationCtrl.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await dataService.updateMyProfile(
        name: _nameCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        about: _aboutCtrl.text.trim(),
        sports: _sports.toList(),
        skillLevel: _skillLevel,
        availableDays: dayOptions.where(_days.contains).toList(),
        timePrefs: [for (final t in timeOptions) if (_times.contains(t.$2)) t.$2],
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('PROFILE UPDATE ERROR: $e');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Profil kaydedilemedi. Lütfen tekrar deneyin.'),
        backgroundColor: RallyColors.accent2,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _toggle(Set<String> set, String value) =>
      setState(() => set.contains(value) ? set.remove(value) : set.add(value));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = CourtThemeProvider.of(context);
    return Scaffold(
      backgroundColor: cp.bg,
      appBar: AppBar(
        backgroundColor: cp.bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: cp.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Profili Düzenle',
          style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22, color: cp.text)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter, Spacing.sm, Spacing.gutter, Spacing.xxl),
        children: [
          _Label('AD SOYAD', cp),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline, size: 18)),
          ),
          _Label('MAHALLE / ŞEHİR', cp),
          TextField(
            controller: _locationCtrl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'örn. Beşiktaş, İstanbul',
              prefixIcon: Icon(Icons.location_on_outlined, size: 18)),
          ),
          _Label('HAKKIMDA', cp),
          TextField(
            controller: _aboutCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Oyun tarzın, sevdiğin kortlar…'),
          ),
          _Label('SPORLAR', cp),
          _PillWrap(
            cp: cp,
            options: [for (final s in sportOptions) (s.$2, '${s.$1}  ${s.$2}')],
            isSelected: _sports.contains,
            onTap: (v) => _toggle(_sports, v),
          ),
          _Label('SEVİYE', cp),
          _PillWrap(
            cp: cp,
            options: [for (final s in skillOptions) (s.$2, '${s.$1}  ${s.$2}')],
            isSelected: (v) => _skillLevel == v,
            onTap: (v) => setState(() => _skillLevel = v),
          ),
          _Label('MÜSAİT GÜNLER', cp),
          _PillWrap(
            cp: cp,
            options: [for (final d in dayOptions) (d, d)],
            isSelected: _days.contains,
            onTap: (v) => _toggle(_days, v),
          ),
          _Label('GÜNÜN SAATİ', cp),
          _PillWrap(
            cp: cp,
            options: [for (final t in timeOptions) (t.$2, '${t.$1}  ${t.$2}')],
            isSelected: _times.contains,
            onTap: (v) => _toggle(_times, v),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter, Spacing.sm, Spacing.gutter, Spacing.lg),
          child: RallyButton(
            label: 'Kaydet',
            onPressed: _canSave ? _save : null,
            loading: _saving,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final CourtPalette cp;
  const _Label(this.text, this.cp);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: Spacing.xl, bottom: Spacing.sm),
        child: Text(text,
          style: RallyType.eyebrow.copyWith(color: cp.muted, letterSpacing: 1.4)),
      );
}

/// Wrap of tappable pills; [options] are (value, display label) pairs.
class _PillWrap extends StatelessWidget {
  final CourtPalette cp;
  final List<(String, String)> options;
  final bool Function(String) isSelected;
  final void Function(String) onTap;

  const _PillWrap({
    required this.cp,
    required this.options,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: options.map((o) {
        final sel = isSelected(o.$1);
        return GestureDetector(
          onTap: () => onTap(o.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: sel ? cp.accentTint : cp.surface,
              borderRadius: BorderRadius.circular(RallyRadius.pill),
              border: Border.all(
                color: sel ? cp.accent : cp.border2, width: 1.5),
            ),
            child: Text(o.$2,
              style: RallyType.titleSM.copyWith(
                color: sel ? cp.accentStrong : cp.text)),
          ),
        );
      }).toList(),
    );
  }
}
