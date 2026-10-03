import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Locale name to pass to `DateFormat` / `NumberFormat`, e.g. `tr` or `en`.
  String get localeName => Localizations.localeOf(this).toString();
}
