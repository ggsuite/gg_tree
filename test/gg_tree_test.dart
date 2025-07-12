// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('GgTree()', () {
    group('foo()', () {
      test('should return foo', () async {
        const ggTree = GgTree();
        expect(ggTree.foo(), 'foo');
      });
    });
  });
}
