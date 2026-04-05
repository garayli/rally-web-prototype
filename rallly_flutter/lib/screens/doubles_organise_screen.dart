import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class DoublesOrganiseScreen extends StatefulWidget {
  final bool isSingles;
  const DoublesOrganiseScreen({super.key, required this.isSingles});

  @override
  State<DoublesOrganiseScreen> createState() => _DoublesOrganiseScreenState();
}

class _DoublesOrganiseScreenState extends State<DoublesOrganiseScreen> {
  Player? _opponent;
  Player? _partner;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _court = '';
  bool _loading = false;

  final _courtCtrl = TextEditingController();

  final _courts = [
    'Highbury Fields',
    'London Fields',
    "Regent's Park",
    'Victoria Park',
    'Parliament Hill',
    'Shoreditch Park',
  ];

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: RallyColors.accent),
        ),
        child: child!,
      ),
    );
    if (dt != null) setState(() => _selectedDate = dt);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: RallyColors.accent),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  bool get _canSubmit => _opponent != null && _selectedDate != null && _selectedTime != null && _court.isNotEmpty;

  void _submit() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isSingles
              ? 'Match request sent to ${_opponent!.name}!'
              : 'Doubles invites sent!'),
          backgroundColor: RallyColors.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  @override
  void dispose() {
    _courtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isSingles ? 'Singles Match' : 'Doubles Match';
    return Scaffold(
      backgroundColor: RallyColors.bg,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
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
            // Opponent
            _SectionLabel(widget.isSingles ? 'CHOOSE OPPONENT' : 'CHOOSE OPPONENT'),
            ..._playerList(
              players: MockData.players,
              selected: _opponent,
              onSelect: (p) => setState(() => _opponent = p),
            ),

            if (!widget.isSingles) ...[
              const SizedBox(height: 20),
              const _SectionLabel('YOUR PARTNER'),
              ..._playerList(
                players: MockData.players.where((p) => p != _opponent).toList(),
                selected: _partner,
                onSelect: (p) => setState(() => _partner = p),
              ),
            ],

            const SizedBox(height: 24),
            const _SectionLabel('DATE & TIME'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.calendar_today_outlined,
                    label: _selectedDate == null
                        ? 'Pick date'
                        : DateFormat('EEE, MMM d').format(_selectedDate!),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.access_time_outlined,
                    label: _selectedTime == null
                        ? 'Pick time'
                        : _selectedTime!.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 120.ms),

            const SizedBox(height: 24),
            const _SectionLabel('COURT'),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _courts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = _courts[i];
                  final selected = _court == c;
                  return GestureDetector(
                    onTap: () => setState(() => _court = c),
                    child: AnimatedContainer(
                      duration: 160.ms,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? RallyColors.accent : RallyColors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: selected ? RallyColors.accent : RallyColors.border2, width: 1.5),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : RallyColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 160.ms),

            const SizedBox(height: 32),
            RallyButton(
              label: widget.isSingles ? 'Send Match Request 🎾' : 'Send Invites 🎾',
              onPressed: _canSubmit ? _submit : null,
              loading: _loading,
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }

  List<Widget> _playerList({
    required List<Player> players,
    required Player? selected,
    required void Function(Player) onSelect,
  }) {
    return players.map((p) {
      final isSelected = selected?.id == p.id;
      return GestureDetector(
        onTap: () => onSelect(p),
        child: AnimatedContainer(
          duration: 160.ms,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? RallyColors.accentLight : RallyColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? RallyColors.accent : RallyColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              PlayerAvatar(
                initials: p.initials,
                gradientStart: p.avatarGradientStart,
                gradientEnd: p.avatarGradientEnd,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('${p.skillLabel} · ${p.location}', style: const TextStyle(fontSize: 12, color: RallyColors.muted)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: RallyColors.accent, size: 22),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RallyColors.muted, letterSpacing: 0.8),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickerTile({required this.icon, required this.label, required this.onTap});

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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
