import '../services/data_service.dart';
import 'app_localizations.dart';

/// Localized, user-facing text for an error thrown by a DataService write.
String dataErrorMessage(AppLocalizations l, Object error) {
  if (error is DataException) {
    return switch (error.error) {
      DataError.notSignedIn => l.errorNotSignedIn,
      DataError.recipientNotRegistered => l.errorRecipientNotRegistered,
      DataError.matchUpdateDenied => l.errorMatchUpdateDenied,
      DataError.ownLobby => l.errorOwnLobby,
      DataError.alreadyRequested => l.errorAlreadyRequested,
    };
  }
  return l.errorUnknown;
}
