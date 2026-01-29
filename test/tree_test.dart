// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';
import 'package:gg_tree/src/tree_data.dart';
import 'package:test/test.dart';

void main() {
  group('Tree', () {
    late Tree<ExampleData> tree;
    late Tree<ExampleData> root;
    late Tree<ExampleData> child;
    late Tree<ExampleData> grandChild;

    setUp(() {
      tree = Tree.example();
      root = tree;
      child = root.children.first;
      grandChild = child.children.first;
    });

    group('Tree(), Tree.root(), Tree.example()', () {
      test('should create an instance', () {
        expect(tree, isNotNull);
      });
    });

    group('key', () {
      test('returns the key', () {
        expect(root.key, 'root');
        expect(child.key, 'child');
        expect(grandChild.key, 'grandChild');
      });
    });

    group('value', () {
      test('returns the value', () {
        expect(root.value.toJson(), exampleJsonPrimitive);
        expect(child.value.toJson(), exampleJsonNested0);
        expect(grandChild.value.toJson(), exampleJsonNested1);
      });
    });

    group('parent', () {
      test('returns the parent', () {
        expect(root.parent, isNull);
        expect(child.parent, same(root));
        expect(grandChild.parent, same(child));
      });
    });

    group('children', () {
      test('returns the children', () {
        expect(root.children.length, 1);
        expect(root.children.first, same(child));
        expect(child.children.length, 1);
        expect(child.children.first, same(grandChild));
        expect(grandChild.children.length, 0);
      });
    });

    group('getOrNull(query)', () {
      group('returns data', () {
        group('with a query', () {
          group('starting with "."', () {
            test('from simple json data', () {
              expect(root.getOrNull<int>('.integerValue'), 42);
              expect(root.getOrNull<double>('.doubleValue'), 3.14159);
              expect(root.getOrNull<bool>('.booleanTrue'), isTrue);
              expect(root.getOrNull<bool>('.booleanFalse'), isFalse);
              expect(root.getOrNull<dynamic>('.nullValue'), null);
            });

            test('from nested json data', () {
              expect(
                child.getOrNull<String>('.objectValue.nestedString'),
                'nested',
              );
            });
          });
        });
      });

      group('returns null on unknown query', () {
        test('from simple json data', () {
          expect(root.getOrNull<int>('.unknown'), isNull);
        });

        test('from nested json data', () {
          expect(child.getOrNull<String>('.objectValue.unknown'), isNull);
        });
      });
    });

    group('get(query)', () {
      group('returns data', () {
        group('with a query', () {
          group('starting with "."', () {
            test('from simple json data', () {
              expect(root.get<int>('.integerValue'), 42);
              expect(root.get<double>('.doubleValue'), 3.14159);
              expect(root.get<bool>('.booleanTrue'), isTrue);
              expect(root.get<bool>('.booleanFalse'), isFalse);
            });

            test('from nested json data', () {
              expect(child.get<String>('.objectValue.nestedString'), 'nested');
            });
          });
        });
      });

      group('throws on unknown query', () {
        test('from simple json data', () {
          var messages = <String>[];
          try {
            root.get<int>('.unknown');
          } catch (e) {
            messages = ((e as dynamic).message as String).split('\n');
          }

          expect(messages, [
            'Cannot resolve query ".unknown" for tree with key "root"',
          ]);
        });
      });
    });

    group('set(key, value)', () {
      test('writes data into the tree', () {
        root.set<int>('.newInteger', 100);
        expect(root.get<int>('.newInteger'), 100);

        child.set<String>('.newString', 'hello');
        expect(child.get<String>('.newString'), 'hello');
      });
    });
  });
}
