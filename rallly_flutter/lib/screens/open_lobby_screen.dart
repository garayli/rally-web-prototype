import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class OpenLobbyScreen extends StatefulWidget {
  const OpenLobbyScreen({super.key});

  @override
  State<OpenLobbyScreen> createState() => _OpenLobbyScreenState();
}

class _OpenLobbyScreenState extends State<OpenLobbyScreen> {
  String _sport = 'Tennis';
  String _skillLevel = 'Any level';
  DateTime? _date;
  TimeOfDay? _time;
  String _court = '';
  final _notesCtrl = TextEditingController();
  bool _isPublic = true;
  bool _loading = false;

  static const _sports = ['Tennis', 'Padel', 'Badminton', 'Squash'];
  static const _skillLevels = ['Any level', 'Beginner', 'Intermediate', 'Advanced', 'Expert'];
  static const _courts = ['Highbury Fields', 'London Fields', "Regent's Park", 'Victoria Park', 'Shoreditch Park'];

  bool get _canSubmit => _date != null && _time != null && _court.isNotEmpty;

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: RallyColors.accent)),
        child: child!,
      ),
    );
    if (dt != null) setState(() => _date = dt);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: RallyColors.accent)),
        child: child!,
      ),
    );
    if (t != null) setState(() => _time = t);
  }

  void _submit() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Open lobby created! Players can now join.'),
          backgroundColor: RallyColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: const Text('Open Lobby', style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
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
            const Text(
              'Create an open slot',
              style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 28, letterSpacing: -1, height: 1.1),
            ).animate().fadeIn(),
            const SizedBox(height: 6),
            const Text(
              'Other players can request to join your session',
              style: TextStyle(color: RallyColors.textSecondary, fontSize: 14, height: 1.5),
            ).animate().fadeIn(delay: 80.ms),
            const SizedBox(height: 28),

            // Sport
            const _Label('SPORT'),
            const SizedBox(height: 8),
            _ChipRow(
              items: _sports,
              selected: _sport,
              onSelect: (v) => setState(() => _sport = v),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),
            const _Label('SKILL LEVEL WELCOME'),
            const SizedBox(height: 8),
            _ChipRow(
              items: _skillLevels,
              selected: _skillLevel,
              onSelect: (v) => setState(() => _skillLevel = v),
            ).animate().fadeIn(delay: 120.ms),

            const SizedBox(height: 20),
            const _Label('DATE & TIME'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PickerBox(
                    icon: Icons.calendar_today_outlined,
                    label: _date == null ? 'Pick date' : DateFormat('EEE, MMM d').format(_date!),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerBox(
                    icon: Icons.access_time_outlined,
                    label: _time == null ? 'Pick time' : _time!.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 140.ms),

            const SizedBox(height: 20),
            const _Label('COURT'),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _courts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _courts[i];
                  final sel = _court == c;
                  return GestureDetector(
                    onTap: () => setState(() => _court = c),
                    child: AnimatedContainer(
                      duration: 160.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? RallyColors.accent : RallyColors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: sel ? RallyColors.accent : RallyColors.border2, width: 1.5),
                      ),
                      child: Text(c, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : RallyColors.textPrimary)),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 160.ms),

            const SizedBox(height: 20),
            const _Label('NOTES (OPTIONAL)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. "Bring your own balls, casual match, beginners welcome"',
              ),
            ).animate().fadeIn(delay: 180.ms),

            const SizedBox(height: 20),
            // Visibility toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RallyColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RallyColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: RallyColors.surface2, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('🔓', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Public lobby', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('Anyone can request to join', style: TextStyle(fontSize: 12, color: RallyColors.muted)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    activeThumbColor: RallyColors.accent,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 28),
            RallyButton(
              label: 'Create Lobby 🎾',
              onPressed: _canSubmit ? _submit : null,
              loading: _loading,
            ).animate().fadeIn(delay: 220.ms),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
  );
}

class _ChipRow extends StatelessWidget {
  final List<String> items;
  final String selected;
  final void Function(String) onSelect;

  const _ChipRow({required this.items, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final sel = selected == item;
          return GestureDetector(
            onTap: () => onSelect(item),
            child: AnimatedContainer(
              duration: 160.ms,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: sel ? RallyColors.accent : RallyColors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: sel ? RallyColors.accent : RallyColors.border2, width: 1.5),
              ),
              child: Text(item, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : RallyColors.textPrimary)),
            ),
          );
        },
      ),
    );
  }
}

class _PickerBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerBox({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: RallyColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: RallyColors.border2, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: RallyColors.muted),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
