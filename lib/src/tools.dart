// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

bool _isLetterOrSlash(int codeUnit) =>
    (codeUnit >= 0x41 && codeUnit <= 0x5A) || // A-Z
    (codeUnit >= 0x61 && codeUnit <= 0x7A) || // a-z
    codeUnit == 0x2F; // /

/// Returns a simple path with only /, numbers and letters
String keepOnlyLetters(String path) {
  for (var i = 0; i < path.length; i++) {
    if (!_isLetterOrSlash(path.codeUnitAt(i))) {
      // Rewrite the rest of the string starting at the first dropped char
      final buffer = StringBuffer(path.substring(0, i));
      for (var j = i + 1; j < path.length; j++) {
        final codeUnit = path.codeUnitAt(j);
        if (_isLetterOrSlash(codeUnit)) {
          buffer.writeCharCode(codeUnit);
        }
      }
      return buffer.toString();
    }
  }

  // Nothing to remove: return the original string without any allocation
  return path;
}
