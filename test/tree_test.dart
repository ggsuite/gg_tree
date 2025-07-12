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
        const tree = Tree(
          item: {'root': 'node'},
          children: {
            'child': Tree(item: {'child': 'node'}, children: {}),
          },
        );

        expect(tree.item, {'root': 'node'});
        expect(tree.children.length, 1);
        expect(tree.children['child']?.item, {'child': 'node'});
        expect(tree.children['child']?.children, isEmpty);
      });
    });

    test('Tree should be immutable', () {
      const tree = Tree(item: {'immutable': true}, children: {});

      expect(
        () => tree.item['newKey'] = 'newValue',
        throwsA(isA<UnsupportedError>()),
      );
    });

    group('example()', () {
      test('should return a valid example tree', () {
        final example = Tree.example();

        expect(example.item, {'hello': 'world'});
        expect(example.item, {'hello': 'world'});
        expect(example.children.length, 2);

        expect(example.children['child1']?.item, {'child1': 'value1'});
        expect(example.children['child1']?.children, isEmpty);

        expect(example.children['child2']?.item, {'child2': 'value2'});
        expect(example.children['child2']?.children.length, 1);
        expect(example.children['child2']?.children['grandchild']?.item, {
          'grandchild': 'value3',
        });
        expect(
          example.children['child2']?.children['grandchild']?.children,
          isEmpty,
        );
      });
    });

    group('fromJson, toJson', () {
      test('should serialize and deserialize correctly', () {
        final original = Tree.example();
        final json = original.toJson();

        expect(json, {
          'item': {'hello': 'world'},
          'children': {
            'child1': {
              'item': {'child1': 'value1'},
            },
            'child2': {
              'item': {'child2': 'value2'},
              'children': {
                'grandchild': {
                  'item': {'grandchild': 'value3'},
                },
              },
            },
          },
        });

        final deserialized = Tree.fromJson(json);

        expect(deserialized.item, original.item);
        expect(deserialized.children.length, original.children.length);
        expect(
          deserialized.children['child1']?.item,
          original.children['child1']?.item,
        );
        expect(
          deserialized.children['child2']?.item,
          original.children['child2']?.item,
        );
        expect(
          deserialized.children['child2']?.children['grandchild']?.item,
          original.children['child2']?.children['grandchild']?.item,
        );
      });
    });
  });
}
