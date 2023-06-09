import 'package:flutter/material.dart';

class PrefixColors {
  final Color bg;
  final Color fg;
  PrefixColors(this.bg, this.fg);
}

Color getLabelBackgroundColor(String label) {
  PrefixColors? result = prefixColorsMap[label];
  return result?.bg ?? Colors.grey;
}

Color getLabelForegroundColor(String label) {
  PrefixColors? result = prefixColorsMap[label];
  return result?.fg ?? Colors.white;
}

final Map<String, PrefixColors> prefixColorsMap = {
  //                                ENGINE
  'ADRIFT': PrefixColors(
    const Color(0xFF0B79D2),
    const Color(0xFFFFFFFF),
  ),
  'Flash': PrefixColors(
    const Color(0xFF616161),
    const Color(0xFFFFFFFF),
  ),
  'HTML': PrefixColors(
    const Color(0xFF54812D),
    const Color(0xFFFFFFFF),
  ),
  'Java': PrefixColors(
    const Color(0xFF52A6B0),
    const Color(0xFFFFFFFF),
  ),
  'Others': PrefixColors(
    const Color(0xFF6C9C34),
    const Color(0xFFFFFFFF),
  ),
  'QSP': PrefixColors(
    const Color(0xFFD32F2F),
    const Color(0xFFFFFFFF),
  ),
  'RAGS': PrefixColors(
    const Color(0xFFC77700),
    const Color(0xFFFFFFFF),
  ),
  'RPGM': PrefixColors(
    const Color(0xFF0B79D1),
    const Color(0xFFFFFFFF),
  ),
  "Ren'Py": PrefixColors(
    const Color(0xFF9D46E3),
    const Color(0xFFFFFFFF),
  ),
  'Tads': PrefixColors(
    const Color(0xFF0B79D1),
    const Color(0xFFFFFFFF),
  ),
  'Unity': PrefixColors(
    const Color(0xFFEA5201),
    const Color(0xFFFFFFFF),
  ),
  'Unreal Engine': PrefixColors(
    const Color(0xFF0D47A1),
    const Color(0xFFFFFFFF),
  ),
  'WebGL': PrefixColors(
    const Color(0xFFFE5901),
    const Color(0xFFFFFFFF),
  ),
  'Wolf RPG': PrefixColors(
    const Color(0xFF39843C),
    const Color(0xFFFFFFFF),
  ),
  //                                OTHER
  'Collection': PrefixColors(
    const Color(0xFF616161),
    const Color(0xFFFFFFFF),
  ),
  'SiteRip': PrefixColors(
    const Color(0xFF6C9C34),
    const Color(0xFFFFFFFF),
  ),
  'VN': PrefixColors(
    const Color(0xFFD32F2F),
    const Color(0xFFFFFFFF),
  ),
  //                            COMICS & STILLS
  'Manga': PrefixColors(
    const Color(0xFF03A9F4),
    const Color(0xFFFFFFFF),
  ),
  'Comics': PrefixColors(
    const Color(0xFFFF9800),
    const Color(0xFF000000),
  ),
  'CG': PrefixColors(
    const Color(0xFFFFEB3B),
    const Color(0xFF000000),
  ),
  'Pinup': PrefixColors(
    const Color(0xFF2196F3),
    const Color(0xFF000000),
  ),
  //                          ANIMATIONS & LOOPS
  'Video': PrefixColors(
    const Color(0xFFFF9800),
    const Color(0xFF000000),
  ),
  'GIF': PrefixColors(
    const Color(0xFF03A9F4),
    const Color(0xFFFFFFFF),
  ),
  'App': PrefixColors(
    const Color(0xFF4CAF50),
    const Color(0xFFFFFFFF),
  ),
  //                                STATUS
  'Abandoned': PrefixColors(
    const Color(0xFFC77700),
    const Color(0xFFFFFFFF),
  ),
  'Completed': PrefixColors(
    const Color(0xFF0B79D1),
    const Color(0xFFFFFFFF),
  ),
  'Onhold': PrefixColors(
    const Color(0xFF03A9F4),
    const Color(0xFFFFFFFF),
  ),
};
