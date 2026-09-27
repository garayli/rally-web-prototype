/// Up to two uppercase initials from a display name ("Leyla Garayli" → "LG").
/// Falls back to '?' so the NOT NULL `profiles.initials` column never gets null.
String initialsOf(String name) {
  final initials = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join()
      .toUpperCase();
  return initials.isEmpty ? '?' : initials;
}
