// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('TreeTools', () {
    group('constructor', () {
      test('should work', () {
        final treeTools = TreeTools.example();
        expect(treeTools, isNotNull);
      });
    });
  });
}
