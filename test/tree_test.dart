// @license
// Copyright (c) 2019 - 2025 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Tree()', () {
    group('constructor', () {
      test('should create a tree with correct item and children', () {
        const tree = Tree<Map<String, dynamic>>(
          item: {'root': 'node'},
          children: [
            Tree(item: {'child': 'node'}, children: []),
          ],
        );

        expect(tree.item, {'root': 'node'});
        expect(tree.children.length, 1);
        expect(tree.children.first.item, {'child': 'node'});
        expect(tree.children.first.children, isEmpty);
      });

      test('Tree should be immutable', () {
        const tree = Tree<Map<String, dynamic>>(
          item: {'immutable': true},
          children: [],
        );

        expect(
          () => tree.item['newKey'] = 'newValue',
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('example()', () {
      test('should return a valid example tree', () {
        final example = Tree.example();

        expect(example.item, {'hello': 'world'});
        expect(example.children.length, 2);

        expect(example.children[0].item, {'child1': 'value1'});
        expect(example.children[0].children, isEmpty);

        expect(example.children[1].item, {'child2': 'value2'});
        expect(example.children[1].children.length, 1);
        expect(example.children[1].children[0].item, {'grandchild': 'value3'});
        expect(example.children[1].children[0].children, isEmpty);
      });
    });
  });
}
