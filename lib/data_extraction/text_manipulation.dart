int? extractIdFromRawInput(String rawInput) {
  final input = rawInput.trim();

  if (stringMatchesId(input)) {
    return int.tryParse(input);
  }

  if (stringMatchesShortLink(input)) {
    RegExp regex = RegExp(r'https://f95zone.to/threads/(\d+)/*');
    Iterable<RegExpMatch> matches = regex.allMatches(input);
    return int.tryParse(matches.first.group(1) ?? 'YOLO');
  }

  if (stringMatchesDotLink(input)) {
    RegExp regex = RegExp(r'\.(\d+)');
    Iterable<RegExpMatch> matches = regex.allMatches(input);
    return int.tryParse(matches.first.group(1) ?? 'YOLO');
  }

  return null;
}

bool stringMatchesId(String str) {
  final regexp = RegExp(r'^[0-9]*$');
  return regexp.hasMatch(str);
}

bool stringMatchesShortLink(String str) {
  final regexp = RegExp(r'^https://f95zone.to/threads/\d+/*');
  return regexp.hasMatch(str);
}

bool stringMatchesDotLink(String str) {
  final regexp = RegExp(r'^https://f95zone.to/threads/.*\.\d+');
  return regexp.hasMatch(str);
}
