// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_golden/gg_golden.dart';
import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';
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

      group('throws, when key is not a valid JSON key', () {
        test('for root constructors', () {
          var messages = <String>[];
          try {
            Tree.example(key: 'invalid-key');
          } catch (e) {
            messages = [(e as dynamic).message as String];
          }

          expect(messages, ['invalid-key is not a valid json identifier']);
        });

        test('for child constructors', () {
          var messages = <String>[];
          try {
            final root = Tree.example();
            Tree(
              key: 'invalid-child-key',
              parent: root,
              value: ExampleData.example(),
            );
          } catch (e) {
            messages = [(e as dynamic).message as String];
          }

          expect(messages, [
            'invalid-child-key is not a valid json identifier',
          ]);
        });
      });

      group('throws, when key starts with underscore', () {
        test('for root constructors', () {
          var messages = <String>[];
          try {
            Tree.example(key: '_forbiddenKey');
          } catch (e) {
            messages = [(e as dynamic).message as String];
          }

          expect(messages, ['Key "_forbiddenKey" must not start with _']);
        });

        test('for child constructors', () {
          var messages = <String>[];
          try {
            final root = Tree.example();
            Tree(
              key: '_forbiddenChildKey',
              parent: root,
              value: ExampleData.example(),
            );
          } catch (e) {
            messages = [(e as dynamic).message as String];
          }

          expect(messages, ['Key "_forbiddenChildKey" must not start with _']);
        });
      });

      group('reassigns all children to the new parent', () {
        test('for root constructors', () {
          // Before
          expect(child.parent, same(root));
          expect(grandChild.parent, same(child));

          // Act
          final newRoot = Tree<ExampleData>.root(
            key: 'newRoot',
            value: ExampleData.example(),
            children: [child, grandChild],
          );

          // After
          expect(child.parent, same(newRoot));
          expect(grandChild.parent, same(newRoot));
        });
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
      group('writes data into the tree', () {
        group('with just a "." query', () {
          test('write the complete node', () {
            root.set('.', {'new': 'object'});
            expect(root.value.data, {'new': 'object'});
          });
        });
        test('with a simple non nested query', () {
          root.set<int>('.integerValue', 123);
          expect(root.get<int>('.integerValue'), 123);
        });

        test('with a nested query', () {
          expect(child.get<String>('.objectValue.nestedString'), 'nested');
          child.set('.objectValue.nestedString', 'change');
          expect(child.get<String>('.objectValue.nestedString'), 'change');
        });
      });
    });

    group('setReadOnly', () {
      group('with recursive = true', () {
        test('sets all children to readonly', () {
          // Before
          expect(root.isReadOnly, isFalse);
          expect(child.isReadOnly, isFalse);
          expect(grandChild.isReadOnly, isFalse);

          // Act
          root.setReadOnly(true, recursive: true);

          // After
          expect(root.isReadOnly, isTrue);
          expect(child.isReadOnly, isTrue);
          expect(grandChild.isReadOnly, isTrue);
        });
      });

      group('with recursive false', () {
        test('sets only this node to readonly', () {
          // Before
          expect(root.isReadOnly, isFalse);
          expect(child.isReadOnly, isFalse);
          expect(grandChild.isReadOnly, isFalse);

          // Act
          root.setReadOnly(true, recursive: false);

          // After
          expect(root.isReadOnly, isTrue);
          expect(child.isReadOnly, isFalse);
          expect(grandChild.isReadOnly, isFalse);
        });
      });

      group('makes all write operations throw', () {
        test('when trying to set parent', () {
          root.setReadOnly(true, recursive: true);

          var message = <String>[];
          try {
            child.parent = null;
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, ['Tree node "child" is readonly']);
        });

        test('when trying to set data', () {
          root.setReadOnly(true, recursive: true);

          var message = <String>[];
          try {
            root.set<int>('.integerValue', 123);
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, ['Tree node "root" is readonly']);
        });
      });
    });

    group('toJson', () {
      test(
        'returns identical tree after serialization and deserialization',
        () async {
          final json = tree.toJson();
          await writeGolden('to_json.json', json);
        },
      );
    });

    group('fromJson', () {
      test('creates a tree from json identical to the original', () async {
        // Create json from original tree
        final json = tree.toJson();
        final newTree = tree.fromJson(json);

        // Check parents
        expect(newTree.parent, isNull);
        for (final child in newTree.children) {
          expect(child.parent, same(newTree));
          for (final grandChild in child.children) {
            expect(grandChild.parent, same(child));
          }
        }

        // Serialize back to json
        final json2 = newTree.toJson();

        // Write golden
        await writeGolden('from_json.json', json2);

        // Compare
        expect(json2, json);
      });
    });

    group('deepCopy', () {
      test('creates an identical copy of the tree', () {
        final copy = tree.deepCopy();

        // Check that the copy is not the same instance
        expect(copy, isNot(same(tree)));

        // Check that the structure is identical
        expect(copy.key, tree.key);
        expect(copy.value.toJson(), tree.value.toJson());
        expect(copy.children.length, tree.children.length);

        final originalChild = tree.children.first;
        final copiedChild = copy.children.first;

        expect(copiedChild, isNot(same(originalChild)));
        expect(copiedChild.key, originalChild.key);
        expect(copiedChild.value.toJson(), originalChild.value.toJson());
        expect(copiedChild.parent, same(copy));
      });
    });

    group('ls', () {
      test('return all paths of the tree', () {
        expect(root.ls(), ['/', '/child', '/child/grandChild']);
      });
    });

    group('make sure children have unique node names', () {
      late Tree<ExampleData> parent;
      late Tree<ExampleData> child0;
      late Tree<ExampleData> child1;
      late Tree<ExampleData> child2;

      final ev = ExampleData.example();

      setUp(() {
        parent = Tree<ExampleData>.root(
          key: 'parent',
          value: ExampleData.example(),
        );

        child0 = Tree<ExampleData>.root(key: 'child', value: ev);
        child1 = Tree<ExampleData>.root(key: 'child', value: ev);
        child2 = Tree<ExampleData>.root(key: 'child', value: ev);
      });

      group('auto correct when nodes have not unique names', () {
        group('when nodes are provided via', () {
          test('constructor', () {
            parent = Tree<ExampleData>.root(
              key: 'name',
              value: ev,
              children: [child0, child1, child2],
            );
            expect(parent.children.elementAt(0).key, 'child0');
            expect(parent.children.elementAt(1).key, 'child1');
            expect(parent.children.elementAt(2).key, 'child2');
          });

          test('via addChildren', () {
            parent.addChildren([child0]);
            expect(parent.children.elementAt(0).key, 'child');

            parent.addChildren([child1]);
            expect(parent.children.elementAt(0).key, 'child0');
            expect(parent.children.elementAt(1).key, 'child1');

            parent.addChildren([child2]);
            expect(parent.children.elementAt(0).key, 'child0');
            expect(parent.children.elementAt(1).key, 'child1');
            expect(parent.children.elementAt(2).key, 'child2');
          });

          test('via setParent', () {
            expect(parent.children.isEmpty, isTrue);

            child0.parent = parent;
            child1.parent = parent;
            child2.parent = parent;

            expect(parent.children.elementAt(0).key, 'child0');
            expect(parent.children.elementAt(1).key, 'child1');
            expect(parent.children.elementAt(2).key, 'child2');
          });
        });

        test('sibling nodes with same name are renamed', () {
          final parent = Tree<ExampleData>.root(key: 'parent', value: ev);
          final child1 = Tree<ExampleData>.root(key: 'child', value: ev);
          final child2 = Tree<ExampleData>.root(key: 'child', value: ev);

          parent.addChildren([child1, child2]);

          expect(parent.children.elementAt(0).key, 'child0');
          expect(parent.children.elementAt(1).key, 'child1');
        });

        test('multiple sibling nodes with same name are renamed', () {
          final parent = Tree<ExampleData>.root(key: 'parent', value: ev);
          final child1 = Tree<ExampleData>.root(key: 'child', value: ev);
          final child2 = Tree<ExampleData>.root(key: 'child', value: ev);
          final child3 = Tree<ExampleData>.root(key: 'child', value: ev);

          parent.addChildren([child1, child2, child3]);

          expect(parent.children.elementAt(0).key, 'child0');
          expect(parent.children.elementAt(1).key, 'child1');
          expect(parent.children.elementAt(2).key, 'child2');
        });
      });
    });
  });
}
