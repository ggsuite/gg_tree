// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/src/tools.dart';
import 'package:test/test.dart';

void main() {
  group('Tools', () {
    group('keepOnlyLetters', () {
      test('removes all non-letter characters', () {
        const path = '/path/to%%#\$/some123_file-name.ext';
        final cleanedPath = keepOnlyLetters(path);
        expect(cleanedPath, '/path/to/somefilenameext');
      });
    });
  });
}
