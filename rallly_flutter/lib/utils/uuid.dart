// Mock/demo player ids ('1', '2'...) aren't valid uuids and have no real
// profiles row — only a real registered opponent (a real uuid id) can be
// notified to confirm a logged result or receive a match request.
final _uuidRe = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);
bool isUuid(String value) => _uuidRe.hasMatch(value);
