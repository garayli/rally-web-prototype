/// Name the `handle_new_user` auth trigger gives a freshly created account
/// before the signup wizard has run.
const placeholderProfileName = 'New Player';

/// Whether a `profiles` row (or null when there is none) is a finished
/// profile. The auth trigger creates a placeholder row, so existence alone
/// isn't enough — the wizard's required fields (name, location) must be set.
bool isProfileComplete(Map<String, dynamic>? row) {
  if (row == null) return false;
  final name = (row['name'] as String? ?? '').trim();
  final location = (row['location'] as String? ?? '').trim();
  return name.isNotEmpty &&
      name != placeholderProfileName &&
      location.isNotEmpty;
}
