import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RallyColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('My Profile',
                style: TextStyle(fontFamily: 'InstrumentSerif', fontSize: 22)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── Profile header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0EBE0), Color(0xFFF5F0E8)],
                ),
                border: Border(bottom: BorderSide(color: RallyColors.border)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                children: [
                  Stack(
                    children: [
                      PlayerAvatar(
                        initials: 'AW',
                        gradientStart: '#e85d3a',
                        gradientEnd: '#f4956d',
                        size: 84,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: RallyColors.border2, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.edit, size: 12,
                                color: RallyColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Alex Wilson',
                      style: TextStyle(
                          fontFamily: 'InstrumentSerif',
                          fontSize: 28,
                          letterSpacing: -1)),
                  const SizedBox(height: 4),
                  const Text('Islington, London',
                      style: TextStyle(
                          fontSize: 13, color: RallyColors.textSecondary)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: RallyColors.border2),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🎾 ',
                            style: TextStyle(fontSize: 14)),
                        Text('NTRP 3.5 — Intermediate',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: RallyColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Stats row ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: RallyColors.border)),
              ),
              child: Row(
                children: [
                  _StatBox(value: '18', label: 'Wins', green: true),
                  _StatBox(value: '7', label: 'Losses'),
                  _StatBox(value: '25', label: 'Played'),
                  _StatBox(value: '4.8★', label: 'Rating'),
                ],
              ),
            ),
          ),

          // ── Settings ───────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              const _SettingsSection(title: 'ACCOUNT'),
              _SettingsItem(
                icon: '👤',
                label: 'Edit Profile',
                sub: 'Update name, photo, bio',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '🎾',
                label: 'Playing Preferences',
                sub: 'Level, court type, format',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '📅',
                label: 'Availability',
                sub: 'Set your weekly schedule',
                onTap: () {},
              ),
              const _SettingsSection(title: 'APP'),
              _SettingsItem(
                icon: '🔔',
                label: 'Notifications',
                sub: 'Match requests, reminders',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '🌙',
                label: 'Appearance',
                sub: 'Light / Dark mode',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '🔒',
                label: 'Privacy & Safety',
                sub: 'Profile visibility',
                onTap: () {},
              ),
              const _SettingsSection(title: 'ABOUT'),
              _SettingsItem(
                icon: '⭐',
                label: 'Rate Rallly',
                sub: 'Leave a review',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '📋',
                label: 'Terms & Privacy',
                onTap: () {},
              ),
              _SettingsItem(
                icon: '🚪',
                label: 'Sign Out',
                onTap: () {},
                isDestructive: true,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool green;

  const _StatBox({required this.value, required this.label, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'InstrumentSerif',
                fontSize: 26,
                color: green ? RallyColors.accent : RallyColors.textPrimary,
                letterSpacing: -1,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: RallyColors.muted,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  const _SettingsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: RallyColors.muted,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.sub,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: RallyColors.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: RallyColors.border),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDestructive
                          ? RallyColors.accent2
                          : RallyColors.textPrimary,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub!,
                      style: const TextStyle(
                          fontSize: 12, color: RallyColors.muted),
                    ),
                ],
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right,
                  color: RallyColors.muted2, size: 20),
          ],
        ),
      ),
    );
  }
}
