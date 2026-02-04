// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// Returns a simple path with only /, numbers and letters
String keepOnlyLetters(String path) =>
    path.replaceAll(RegExp(r'[^a-zA-Z/]'), '');
