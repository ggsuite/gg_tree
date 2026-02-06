// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_golden/gg_golden.dart';
import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Tree', () {
    late Tree<ExampleData> root;
    late Tree<ExampleData> grandpa;
    late Tree<ExampleData> dad;
    late Tree<ExampleData> me;
    late Tree<ExampleData> brother;
    late Tree<ExampleData> sister;
    late Tree<ExampleData> child;
    late Tree<ExampleData> grandchild;

    setUp(() {
      (root, grandpa, dad, me, brother, sister, child, grandchild) =
          Tree.exampleNodes();
    });

    group('toString', () {
      test('should return a string representation of the tree', () {
        expect(me.toString(), 'me');
      });
    });

    group('Tree(), Tree.root(), Tree.example()', () {
      test('should create an instance', () {
        expect(root, isNotNull);
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
              data: ExampleData.example(),
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
              data: ExampleData.example(),
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
          expect(child.parent, same(me));
          expect(grandchild.parent, same(child));

          // Act
          final newRoot = Tree<ExampleData>.root(
            key: 'newRoot',
            data: ExampleData.example(),
            children: [child, grandchild],
          );

          // After
          expect(child.parent, same(newRoot));
          expect(grandchild.parent, same(newRoot));
        });
      });
    });

    group('key', () {
      test('returns the key', () {
        expect(root.key, 'root');
        expect(child.key, 'child');
        expect(grandchild.key, 'grandchild');
      });
    });

    group('data', () {
      test('returns the value', () {
        expect(root.data.toJson(), {
          'me': 'root',
          'hiRoot': 'Hi from root.',
          'isAncestor': true,
        });
        expect(child.data.toJson(), {
          'me': 'child',
          'hiChild': 'Hi from child.',
          'isAncestor': false,
          'nums': {
            'string': 'Hello, World',
            'int': 42,
            'double': 3.14159,
            'true': true,
            'false': false,
            'null': null,
          },
        });
        expect(grandchild.data.toJson(), {
          'me': 'grandchild',
          'hiGrandchild': 'Hi from grandchild.',
          'isAncestor': false,
          'nums': {
            'string': 'Hello, World',
            'int': 42,
            'double': 3.14159,
            'true': true,
            'false': false,
            'null': null,
          },
        });
      });
    });

    group('pathSegments', () {
      test('returns the path segments', () {
        expect(root.pathSegments, isEmpty);
        expect(grandpa.pathSegments, ['grandpa']);
        expect(dad.pathSegments, ['grandpa', 'dad']);
        expect(me.pathSegments, ['grandpa', 'dad', 'me']);
        expect(child.pathSegments, ['grandpa', 'dad', 'me', 'child']);
        expect(grandchild.pathSegments, [
          'grandpa',
          'dad',
          'me',
          'child',
          'grandchild',
        ]);
      });
    });

    group('path', () {
      test('returns the path as string', () {
        expect(root.path, '/');
        expect(grandpa.path, '/grandpa');
        expect(dad.path, '/grandpa/dad');
        expect(me.path, '/grandpa/dad/me');
        expect(child.path, '/grandpa/dad/me/child');
        expect(grandchild.path, '/grandpa/dad/me/child/grandchild');
      });
    });

    group('pathSimple', () {
      test('returns a simple path with only /, numbers and letters', () {
        final parent = Tree<ExampleData>.root(
          key: 'parent123',
          data: ExampleData.example(),
        );

        final child = Tree<ExampleData>(
          key: 'child_456',
          parent: parent,
          data: ExampleData.example(),
        );

        final grandChild = Tree<ExampleData>(
          key: 'grand_child789',
          parent: child,
          data: ExampleData.example(),
        );

        expect(grandChild.pathSimple, '/child/grandchild');
      });
    });

    group('pathToTreeMap', () {
      test('returns a map of all paths to their corresponding tree nodes', () {
        final map = root.pathToTreeMap();
        expect(map.length, 8);
        expect(map['/'], same(root));
        expect(map['/grandpa'], same(grandpa));
        expect(map['/grandpa/dad'], same(dad));
        expect(map['/grandpa/dad/me'], same(me));
        expect(map['/grandpa/dad/brother'], same(brother));
        expect(map['/grandpa/dad/sister'], same(sister));
        expect(map['/grandpa/dad/me/child'], same(child));
        expect(map['/grandpa/dad/me/child/grandchild'], same(grandchild));

        final map2 = me.pathToTreeMap();
        expect(map2.length, 3);
        expect(map2['/'], same(me));
        expect(map2['/child'], same(child));
        expect(map2['/child/grandchild'], same(grandchild));

        final map3 = me.pathToTreeMap(
          where: (node) => node.key.startsWith('g'),
        );
        expect(map3.length, 1);
        expect(map3['/child/grandchild'], same(grandchild));
      });
    });

    group('parent', () {
      test('returns the parent', () {
        expect(root.parent, isNull);
        expect(child.parent, same(me));
        expect(grandchild.parent, same(child));
      });
    });

    group('children', () {
      test('returns the children', () {
        expect(root.children.length, 1);
        expect(root.children.first, same(grandpa));
        expect(grandpa.children.length, 1);
        expect(grandpa.children.first, same(dad));
        expect(grandchild.children.length, 0);
      });
    });

    group('hasChildWithKey', () {
      test('returns true if a child with the given key exists', () {
        expect(root.hasChildWithKey('grandpa'), isTrue);
        expect(grandpa.hasChildWithKey('dad'), isTrue);
        expect(dad.hasChildWithKey('me'), isTrue);
        expect(me.hasChildWithKey('child'), isTrue);
        expect(child.hasChildWithKey('grandchild'), isTrue);
      });

      test('returns false if a child with the given key does not exist', () {
        expect(root.hasChildWithKey('dad'), isFalse);
        expect(grandpa.hasChildWithKey('me'), isFalse);
        expect(dad.hasChildWithKey('child'), isFalse);
        expect(me.hasChildWithKey('grandchild'), isFalse);
        expect(child.hasChildWithKey('nonExisting'), isFalse);
      });
    });

    group('root', () {
      test('returns the root node', () {
        expect(root.root, same(root));
        expect(grandpa.root, same(root));
        expect(dad.root, same(root));
        expect(me.root, same(root));
        expect(child.root, same(root));
        expect(grandchild.root, same(root));
      });
    });

    group('relative', () {
      test('returns the child with the given key', () {
        expect(me.relative(['']), same(me));
        expect(me.relative([]), same(me));
        expect(me.relative(['child']), same(child));
        expect(me.relative(['.', 'child']), same(child));
        expect(me.relative(['..', 'me']), same(me));
        expect(me.relative(['..', '..', 'dad']), same(dad));
        expect(me.relative(['child', 'grandchild']), same(grandchild));
        expect(me.relative(['child', '..', 'child']), same(child));
        expect(me.relative(['...', 'child']), isNull);
      });
    });

    group('absolute', () {
      test('returns the node at the given absolute path', () {
        expect(root.absolute([]), same(root));
        expect(root.absolute(['root']), isNull);
        expect(root.absolute(['grandpa']), same(grandpa));
        expect(root.absolute(['grandpa', 'dad', 'me', 'child']), same(child));
        expect(
          grandpa.absolute(['grandpa', 'dad', 'me', 'child']),
          same(child),
        );

        expect(dad.absolute(['grandpa', 'dad', 'me', 'child']), same(child));

        expect(
          me.absolute(['grandpa', 'dad', 'me', 'child', 'grandchild']),
          same(grandchild),
        );
        expect(root.absolute(['nonExisting']), isNull);
        expect(root.absolute(['grandpa', 'nonExisting']), isNull);
      });
    });

    group('childByPathOrNull', () {
      test('returns the child node at the given path or null if not found', () {
        expect(me.childByPathOrNull('/'), same(me));
        expect(me.childByPathOrNull('./'), same(me));
        expect(me.childByPathOrNull('.'), same(me));
        expect(me.childByPathOrNull('..'), same(dad));
        expect(me.childByPathOrNull('child'), same(child));
        expect(me.childByPathOrNull('child/grandchild'), same(grandchild));
        expect(me.childByPathOrNull('unknown'), isNull);
      });
    });

    group('childByPath', () {
      test('returns the child node at the given path', () {
        expect(me.childByPath('/'), same(me));
        expect(me.childByPath('./'), same(me));
        expect(me.childByPath('.'), same(me));
        expect(me.childByPath('..'), same(dad));
        expect(me.childByPath('child'), same(child));
        expect(me.childByPath('child/grandchild'), same(grandchild));
      });

      test('throws when the child node is not found', () {
        var messages = <String>[];
        try {
          me.childByPath('unknown');
        } catch (e) {
          messages = ((e as dynamic).message as String).split('\n');
        }

        expect(messages, [
          'Could not find node "unknown"',
          '',
          'Possible paths:',
          '  - .',
          '  - ./node',
          '  - ./child',
          '  - ./child/node',
          '  - ./child/grandchild',
          '  - ./child/grandchild/node',
        ]);
      });
    });

    group('findNode(path)', () {
      test('Empty paths are pointed to self', () {
        expect(me.findNode(''), same(me));
      });

      group('absolute', () {
        test('returns same result as findNodeOrNull', () {
          final a = me.findNode('/grandpa/dad/me/child');
          final b = me.findNodeOrNull('/grandpa/dad/me/child');
          expect(a, same(b));
          expect(a, isNotNull);
        });

        group('throws when node is not found', () {
          test('and a child node is not found', () {
            var messages = <String>[];
            try {
              me.findNode('/grandpa/dad/me/unknown');
            } catch (e) {
              messages = ((e as dynamic).message as String).split('\n');
            }

            expect(messages, [
              'Could not find node "/grandpa/dad/me/unknown"',
              '',
              'Possible paths:',
              '  - /grandpa/dad/me',
              '  - /grandpa/dad/me/node',
              '  - /grandpa/dad/me/child',
              '  - /grandpa/dad/me/child/node',
              '  - /grandpa/dad/me/child/grandchild',
              '  - /grandpa/dad/me/child/grandchild/node',
            ]);
          });

          test('and an ancestor node is not found', () {
            var message = <String>[];
            try {
              me.findNode('/grandpa/dad/unknown');
            } catch (e) {
              message = (e as dynamic).message.toString().trim().split('\n');
            }

            expect(message, [
              'Could not find node "/grandpa/dad/unknown"',
              '',
              'Possible paths:',
              '  - /grandpa/dad',
              '  - /grandpa/dad/node',
              '  - /grandpa/dad/child',
              '  - /grandpa/dad/child/node',
              '  - /grandpa/dad/child/grandchild',
              '  - /grandpa/dad/child/grandchild/node',
            ]);
          });
        });
      });

      group('relative', () {
        test('returns same result as findNodeOrNull', () {
          final a = me.findNode('../me/child');
          final b = me.findNodeOrNull('../me/child');
          expect(a, same(b));
          expect(a, isNotNull);
        });

        test('throws when node is not found', () {
          var messages = <String>[];
          try {
            me.findNode('../me/unknown');
          } catch (e) {
            messages = ((e as dynamic).message as String).split('\n');
          }

          expect(messages, [
            'Could not find node "../me/unknown"',
            '',
            'Possible paths:',
            '  - ../me',
            '  - ../me/node',
            '  - ../me/child',
            '  - ../me/child/node',
            '  - ../me/child/grandchild',
            '  - ../me/child/grandchild/node',
          ]);
        });
      });
    });

    group('findNodeOrNull(path)', () {
      group('relative', () {
        test('throws when path is just ...', () {
          var message = <String>[];
          try {
            me.findNodeOrNull('...');
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, [
            'Path "..." must be followed by at least one segment',
          ]);
        });

        test('returns self if path is empty', () {
          expect(me.findNodeOrNull(''), same(me));
        });
        test('searches from self when path starts with .', () {
          expect(me.findNodeOrNull('.'), same(me));
          expect(me.findNodeOrNull('./child'), same(child));
          expect(me.findNodeOrNull('./child/grandchild'), same(grandchild));
        });

        test('searches from parent when path is ..', () {
          expect(me.findNodeOrNull('..'), same(dad));
          expect(me.findNodeOrNull('../me'), same(me));
          expect(me.findNodeOrNull('../me/child'), same(child));
          expect(me.findNodeOrNull('../me/child/grandchild'), same(grandchild));
        });

        test('searches from ancestor when path starts with ...', () {
          expect(me.findNodeOrNull('.../me'), same(me));
          expect(me.findNodeOrNull('.../me/child'), same(child));
          expect(
            me.findNodeOrNull('.../me/child/grandchild'),
            same(grandchild),
          );
          expect(me.findNodeOrNull('.../grandpa/dad'), same(dad));
        });

        test('allows to combine multiple .. and . operators', () {
          expect(me.findNodeOrNull('../..'), same(grandpa));
          expect(me.findNodeOrNull('../../dad'), same(dad));
          expect(me.findNodeOrNull('../../dad/me/child'), same(child));
        });
      });

      group('absolute', () {
        test('returns root if path starts with /', () {
          expect(me.findNodeOrNull('/'), same(root));
        });
        test('searches from root when path starts with /', () {
          expect(me.findNodeOrNull('/grandpa'), same(grandpa));
          expect(me.findNodeOrNull('/grandpa/dad/me/child'), same(child));
          expect(
            me.findNodeOrNull('/grandpa/dad/me/child/grandchild'),
            same(grandchild),
          );

          expect(me.findNodeOrNull('/dad/me/child/grandchild'), isNull);
        });

        test('skips a single segments when a * is found', () {
          expect(me.findNodeOrNull('/grandpa/**/child'), same(child));
          expect(me.findNodeOrNull('/grandpa/*/me/child'), same(child));
          expect(me.findNodeOrNull('/grandpa/dad/*/child'), same(child));
          expect(me.findNodeOrNull('/grandpa/*/*/child'), same(child));
          expect(me.findNodeOrNull('/grandpa/**/me'), same(me));
          expect(me.findNodeOrNull('/grandpa/**/me/child'), same(child));
          expect(me.findNodeOrNull('/**/me/child'), same(child));
        });
      });
    });

    group('get', () {
      group('throws', () {
        test('when node is not found', () {
          var message = <String>[];
          try {
            me.get<String>('wrong/node#field');
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, [
            'Could not find node "wrong/node"',
            '',
            'Possible paths:',
            '  - .',
            '  - ./node',
            '  - ./child',
            '  - ./child/node',
            '  - ./child/grandchild',
            '  - ./child/grandchild/node',
          ]);
        });

        test('when the field is not found', () {
          var message = <String>[];
          try {
            me.get<String>('../#wrongField');
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, [
            'Value at path "wrongField/" not found.',
            '',
            'Available paths:',
            '  - .',
            '  - ./me',
            '  - ./hiDad',
            '  - ./isAncestor',
            '  - ./nums',
            '  - ./nums/string',
            '  - ./nums/int',
            '  - ./nums/double',
            '  - ./nums/true',
            '  - ./nums/false',
            '  - ./nums/null',
          ]);
        });
      });

      group('returns data from', () {
        group('nodes directly', () {
          test('using ./', () {
            expect(me.get<String>('./#hiMe'), 'Hi from me.');

            expect(me.get<int>('./#nums/int'), 42);
            expect(me.get<double>('./#nums/double'), 3.14159);
            expect(me.get<bool>('./#nums/true'), isTrue);
            expect(me.get<bool>('./#nums/false'), isFalse);
          });

          group('parent node', () {
            test('using ../', () {
              expect(me.get<String>('../#hiDad'), 'Hi from dad.');

              expect(me.get<int>('../#nums/int'), 42);
              expect(me.get<double>('../#nums/double'), 3.14159);
              expect(me.get<bool>('../#nums/true'), isTrue);
              expect(me.get<bool>('../#nums/false'), isFalse);
            });
          });

          group('self or any ancestors', () {
            test('using no operator', () {
              /*
              expect(me.get<String>('#hiRoot'), 'Hi from root.');
              expect(me.get<String>('#hiGrandpa'), 'Hi from grandpa.');
              expect(me.get<String>('#hiDad'), 'Hi from dad.');
              expect(me.get<String>('#hiMe'), 'Hi from me.');

              expect(me.get<int>('#nums/int'), 42);
              expect(me.get<double>('#nums/double'), 3.14159);
              expect(me.get<bool>('#nums/true'), isTrue);
              expect(me.get<bool>('#nums/false'), isFalse);
              */
            });
          });
        });

        group('child nodes', () {
          group('i.e. from own child nodes', () {
            test('using ./child', () {
              expect(me.get<String>('./child#hiChild'), 'Hi from child.');

              expect(me.get<int>('./child#nums/int'), 42);
              expect(me.get<double>('./child#nums/double'), 3.14159);
              expect(me.get<bool>('./child#nums/true'), isTrue);
              expect(me.get<bool>('./child#nums/false'), isFalse);
            });

            /* test('using ./child/grandchild', () {
              expect(
                me.get<String>('./child/grandchild#hiGrandchild'),
                'Hi from grandchild.',
              );

              expect(me.get<String>('./child/grandchild#hiChild'), isNull);

              expect(me.get<String>('./child/grandchild#hiGrandpa'), isNull);

              expect(me.get<int>('./child/grandchild#nums/int'), 42);
              expect(me.get<double>('./child/grandchild#nums/double'), 3.14159);
              expect(me.get<bool>('./child/grandchild#nums/true'), isTrue);
              expect(me.get<bool>('./child/grandchild#nums/false'), isFalse);
            });*/
          });
        });

        group('the node itself', () {
          group('using node', () {
            test('node/key', () {
              expect(me.getOrNull<String>('./#node/key'), 'me');
            });
            test('node/childCount', () {
              expect(me.getOrNull<int>('./#node/childCount'), 1);
              expect(dad.getOrNull<int>('./#node/childCount'), 3);
            });
            test('node/index', () {
              expect(me.getOrNull<int>('./#node/index'), 0);
              expect(brother.getOrNull<int>('./#node/index'), 1);
              expect(sister.getOrNull<int>('./#node/index'), 2);
              expect(root.getOrNull<int>('./#node/index'), 0);
            });
            test('node/siblingsCount', () {
              expect(me.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(brother.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(sister.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(root.getOrNull<int>('./#node/siblingsCount'), 1);
            });
            test('node/reverseIndex', () {
              expect(me.getOrNull<int>('./#node/reverseIndex'), 2);
              expect(brother.getOrNull<int>('./#node/reverseIndex'), 1);
              expect(sister.getOrNull<int>('./#node/reverseIndex'), 0);
              expect(root.getOrNull<int>('./#node/reverseIndex'), 0);
            });
            test('node/path', () {
              expect(me.getOrNull<String>('./#node/path'), '/grandpa/dad/me');
              expect(
                brother.getOrNull<String>('./#node/path'),
                '/grandpa/dad/brother',
              );
              expect(
                sister.getOrNull<String>('./#node/path'),
                '/grandpa/dad/sister',
              );
              expect(root.getOrNull<String>('./#node/path'), '/');
            });
            test('node/pathSimple', () {
              me.key = 'me89';
              brother.key = 'brother_90';

              expect(
                me.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/me',
              );
              expect(
                brother.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/brother',
              );
              expect(
                sister.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/sister',
              );
              expect(root.getOrNull<String>('./#node/pathSimple'), '/');
            });
            test('node/isRoot', () {
              expect(root.getOrNull<bool>('./#node/isRoot'), isTrue);
              expect(sister.getOrNull<bool>('./#node/isRoot'), isFalse);
            });
          });
        });
      });
    });

    group('getOrNull, get', () {
      group('returns null', () {
        test('when the node is not found', () {
          expect(me.getOrNull<String>('..#wrong'), isNull);
          expect(me.getOrNull<String>('..#me'), 'dad');
        });
        test('when the json path is not found', () {});
      });
      group('returns data from', () {
        group('nodes directly', () {
          test('using ./', () {
            expect(me.getOrNull<String>('./#hiRoot'), isNull);
            expect(me.getOrNull<String>('./#hiGrandpa'), isNull);
            expect(me.getOrNull<String>('./#hiDad'), isNull);
            expect(me.getOrNull<String>('./#hiMe'), 'Hi from me.');

            expect(me.getOrNull<int>('./#nums/int'), 42);
            expect(me.getOrNull<double>('./#nums/double'), 3.14159);
            expect(me.getOrNull<bool>('./#nums/true'), isTrue);
            expect(me.getOrNull<bool>('./#nums/false'), isFalse);
          });

          group('parent node', () {
            test('using ../', () {
              expect(me.getOrNull<String>('../#hiMe'), isNull);

              expect(me.getOrNull<String>('../#hiRoot'), isNull);
              expect(me.getOrNull<String>('../#hiGrandpa'), isNull);
              expect(me.getOrNull<String>('../#hiDad'), 'Hi from dad.');

              expect(me.getOrNull<int>('../#nums/int'), 42);
              expect(me.getOrNull<double>('../#nums/double'), 3.14159);
              expect(me.getOrNull<bool>('../#nums/true'), isTrue);
              expect(me.getOrNull<bool>('../#nums/false'), isFalse);
            });
          });

          group('self or any ancestors', () {
            test('using no operator', () {
              expect(me.getOrNull<String>('#hiRoot'), 'Hi from root.');
              expect(me.getOrNull<String>('#hiGrandpa'), 'Hi from grandpa.');
              expect(me.getOrNull<String>('#hiDad'), 'Hi from dad.');
              expect(me.getOrNull<String>('#hiMe'), 'Hi from me.');

              expect(me.getOrNull<int>('#nums/int'), 42);
              expect(me.getOrNull<double>('#nums/double'), 3.14159);
              expect(me.getOrNull<bool>('#nums/true'), isTrue);
              expect(me.getOrNull<bool>('#nums/false'), isFalse);
            });
          });
        });

        group('child nodes', () {
          group('i.e. from own child nodes', () {
            test('using ./child', () {
              expect(me.getOrNull<String>('./child#hiGrandchild'), isNull);
              expect(me.getOrNull<String>('./child#hiChild'), 'Hi from child.');
              expect(me.getOrNull<String>('./child#hiRoot'), isNull);
              expect(me.getOrNull<String>('./child#hiGrandpa'), isNull);
              expect(me.getOrNull<String>('./child#hiDad'), isNull);
              expect(me.getOrNull<String>('./child#hiMe'), isNull);

              expect(me.getOrNull<int>('./child#nums/int'), 42);
              expect(me.getOrNull<double>('./child#nums/double'), 3.14159);
              expect(me.getOrNull<bool>('./child#nums/true'), isTrue);
              expect(me.getOrNull<bool>('./child#nums/false'), isFalse);
            });

            test('using ./child/grandchild', () {
              expect(
                me.getOrNull<String>('./child/grandchild#hiGrandchild'),
                'Hi from grandchild.',
              );

              expect(
                me.getOrNull<String>('./child/grandchild#hiChild'),
                isNull,
              );
              expect(me.getOrNull<String>('./child/grandchild#hiRoot'), isNull);
              expect(
                me.getOrNull<String>('./child/grandchild#hiGrandpa'),
                isNull,
              );
              expect(me.getOrNull<String>('./child/grandchild#hiDad'), isNull);
              expect(me.getOrNull<String>('./child/grandchild#hiMe'), isNull);

              expect(me.getOrNull<int>('./child/grandchild#nums/int'), 42);
              expect(
                me.getOrNull<double>('./child/grandchild#nums/double'),
                3.14159,
              );
              expect(
                me.getOrNull<bool>('./child/grandchild#nums/true'),
                isTrue,
              );
              expect(
                me.getOrNull<bool>('./child/grandchild#nums/false'),
                isFalse,
              );
            });
          });
        });

        group('the node itself', () {
          group('using node', () {
            test('node/key', () {
              expect(me.getOrNull<String>('./#node/key'), 'me');
            });
            test('node/childCount', () {
              expect(me.getOrNull<int>('./#node/childCount'), 1);
              expect(dad.getOrNull<int>('./#node/childCount'), 3);
            });
            test('node/index', () {
              expect(me.getOrNull<int>('./#node/index'), 0);
              expect(brother.getOrNull<int>('./#node/index'), 1);
              expect(sister.getOrNull<int>('./#node/index'), 2);
              expect(root.getOrNull<int>('./#node/index'), 0);
            });
            test('node/siblingsCount', () {
              expect(me.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(brother.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(sister.getOrNull<int>('./#node/siblingsCount'), 3);
              expect(root.getOrNull<int>('./#node/siblingsCount'), 1);
            });
            test('node/reverseIndex', () {
              expect(me.getOrNull<int>('./#node/reverseIndex'), 2);
              expect(brother.getOrNull<int>('./#node/reverseIndex'), 1);
              expect(sister.getOrNull<int>('./#node/reverseIndex'), 0);
              expect(root.getOrNull<int>('./#node/reverseIndex'), 0);
            });
            test('node/path', () {
              expect(me.getOrNull<String>('./#node/path'), '/grandpa/dad/me');
              expect(
                brother.getOrNull<String>('./#node/path'),
                '/grandpa/dad/brother',
              );
              expect(
                sister.getOrNull<String>('./#node/path'),
                '/grandpa/dad/sister',
              );
              expect(root.getOrNull<String>('./#node/path'), '/');
            });
            test('node/pathSimple', () {
              me.key = 'me89';
              brother.key = 'brother_90';

              expect(
                me.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/me',
              );
              expect(
                brother.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/brother',
              );
              expect(
                sister.getOrNull<String>('./#node/pathSimple'),
                '/grandpa/dad/sister',
              );
              expect(root.getOrNull<String>('./#node/pathSimple'), '/');
            });
            test('node/isRoot', () {
              expect(root.getOrNull<bool>('./#node/isRoot'), isTrue);
              expect(sister.getOrNull<bool>('./#node/isRoot'), isFalse);
            });
          });
        });
      });
    });

    group('set(key, value)', () {
      test('writes data into the tree', () {
        me.set('../#', {'hello': 'world'});
        expect(dad.data.data, {'hello': 'world'});

        me.set('./#', {'new': 'object'});
        expect(me.data.data, {'new': 'object'});

        me.set('./#/new', 'newValue');
        expect(me.data.data, {'new': 'newValue'});

        me.set('./#/num', 10, extend: true);
        expect(me.data.data, {'new': 'newValue', 'num': 10});

        me.set('./#/num', 11);
        expect(me.data.data, {'new': 'newValue', 'num': 11});

        me.set('/#/num', 11, extend: true);
        expect(root.get<int>('#num'), 11);
        expect(me.get<int>('/#num'), 11);
      });
    });

    group('setReadOnly', () {
      group('with recursive = true', () {
        test('sets all children to readonly', () {
          // Before
          expect(root.isReadOnly, isFalse);
          expect(child.isReadOnly, isFalse);
          expect(grandchild.isReadOnly, isFalse);

          // Act
          root.setReadOnly(true, recursive: true);

          // After
          expect(root.isReadOnly, isTrue);
          expect(child.isReadOnly, isTrue);
          expect(grandchild.isReadOnly, isTrue);
        });
      });

      group('with recursive false', () {
        test('sets only this node to readonly', () {
          // Before
          expect(root.isReadOnly, isFalse);
          expect(child.isReadOnly, isFalse);
          expect(grandchild.isReadOnly, isFalse);

          // Act
          root.setReadOnly(true, recursive: false);

          // After
          expect(root.isReadOnly, isTrue);
          expect(child.isReadOnly, isFalse);
          expect(grandchild.isReadOnly, isFalse);
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
            root.set<int>('.int', 123);
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
          final json = root.toJson();
          await writeGolden('to_json.json', json);
        },
      );
    });

    group('fromJson', () {
      test('creates a tree from json identical to the original', () async {
        // Create json from original tree
        final json = root.toJson();
        final newTree = root.fromJson(json);

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
        final copy = root.deepCopy();

        // Check that the copy is not the same instance
        expect(copy, isNot(same(root)));

        // Check that the structure is identical
        expect(copy.key, root.key);
        expect(copy.data.toJson(), root.data.toJson());
        expect(copy.children.length, root.children.length);

        final originalChild = root.children.first;
        final copiedChild = copy.children.first;

        expect(copiedChild, isNot(same(originalChild)));
        expect(copiedChild.key, originalChild.key);
        expect(copiedChild.data.toJson(), originalChild.data.toJson());
        expect(copiedChild.parent, same(copy));
      });
    });

    group('ls', () {
      test('return all paths of the tree', () {
        expect(root.ls(), [
          '.',
          './node',
          './grandpa',
          './grandpa/node',
          './grandpa/dad',
          './grandpa/dad/node',
          './grandpa/dad/me',
          './grandpa/dad/me/node',
          './grandpa/dad/me/child',
          './grandpa/dad/me/child/node',
          './grandpa/dad/me/child/grandchild',
          './grandpa/dad/me/child/grandchild/node',
          './grandpa/dad/brother',
          './grandpa/dad/brother/node',
          './grandpa/dad/sister',
          './grandpa/dad/sister/node',
        ]);

        expect(me.ls(), [
          '.',
          './node',
          './child',
          './child/node',
          './child/grandchild',
          './child/grandchild/node',
        ]);
      });

      group('with where', () {
        test('returns all paths matching the given condition', () {
          expect(root.ls(where: (node) => node.key.startsWith('g')), [
            './grandpa',
            './grandpa/node',
            './grandpa/dad/me/child/grandchild',
            './grandpa/dad/me/child/grandchild/node',
          ]);

          expect(me.ls(where: (node) => node.key.contains('h')), [
            './child',
            './child/node',
            './child/grandchild',
            './child/grandchild/node',
          ]);
        });
      });
    });

    group('lsNodes', () {
      test('returns all nodes in the tree', () {
        expect(root.lsNodes(), [
          root,
          grandpa,
          dad,
          me,
          child,
          grandchild,
          brother,
          sister,
        ]);
        expect(me.lsNodes(), [me, child, grandchild]);
      });
    });

    group('lsNodesWhere', () {
      test('returns all nodes matching the given condition', () {
        expect(root.lsNodesWhere((node) => node.key.startsWith('g')), [
          grandpa,
          grandchild,
        ]);

        expect(me.lsNodesWhere((node) => node.key.contains('h')), [
          child,
          grandchild,
        ]);
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
          data: ExampleData.example(),
        );

        child0 = Tree<ExampleData>.root(key: 'child', data: ev);
        child1 = Tree<ExampleData>.root(key: 'child', data: ev);
        child2 = Tree<ExampleData>.root(key: 'child', data: ev);
      });

      group('auto correct when nodes have not unique names', () {
        group('when nodes are provided via', () {
          test('constructor', () {
            parent = Tree<ExampleData>.root(
              key: 'name',
              data: ev,
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
          final parent = Tree<ExampleData>.root(key: 'parent', data: ev);
          final child1 = Tree<ExampleData>.root(key: 'child', data: ev);
          final child2 = Tree<ExampleData>.root(key: 'child', data: ev);

          parent.addChildren([child1, child2]);

          expect(parent.children.elementAt(0).key, 'child0');
          expect(parent.children.elementAt(1).key, 'child1');
        });

        test('multiple sibling nodes with same name are renamed', () {
          final parent = Tree<ExampleData>.root(key: 'parent', data: ev);
          final child1 = Tree<ExampleData>.root(key: 'child', data: ev);
          final child2 = Tree<ExampleData>.root(key: 'child', data: ev);
          final child3 = Tree<ExampleData>.root(key: 'child', data: ev);

          parent.addChildren([child1, child2, child3]);

          expect(parent.children.elementAt(0).key, 'child0');
          expect(parent.children.elementAt(1).key, 'child1');
          expect(parent.children.elementAt(2).key, 'child2');
        });
      });
    });

    group('ancestors', () {
      test('returns a list of all ancestors', () {
        expect(me.ancestors(), [dad, grandpa, root]);
        expect(me.ancestors(includeSelf: true), [me, dad, grandpa, root]);
        expect(me.ancestors(includeRoot: false), [dad, grandpa]);
        expect(me.ancestors(startAtRoot: true), [root, grandpa, dad]);
        expect(
          me.ancestors(
            startAtRoot: true,
            includeRoot: false,
            includeSelf: true,
          ),
          [grandpa, dad, me],
        );
      });
    });

    group('set key, get key', () {
      test('allows to set and get the key', () {
        expect(me.key, 'me');
        me.key = 'newMe';
        expect(me.key, 'newMe');
      });

      test('throws when setting an invalid key', () {
        var messages = <String>[];
        try {
          me.key = 'invalid-key';
        } catch (e) {
          messages = [(e as dynamic).message as String];
        }

        expect(messages, ['invalid-key is not a valid json identifier']);
      });

      test('throws when readonly is set', () {
        me.setReadOnly(true);

        var messages = <String>[];
        try {
          me.key = 'newKey';
        } catch (e) {
          messages = [(e as dynamic).message as String];
        }
        expect(messages, ['Tree node "me" is readonly']);
      });

      test('makes keys unique among siblings when setting key', () {
        final parent = Tree<ExampleData>.root(
          key: 'parent',
          data: ExampleData.example(),
        );

        final child1 = Tree<ExampleData>.root(
          key: 'child',
          data: ExampleData.example(),
        );
        final child2 = Tree<ExampleData>.root(
          key: 'child',
          data: ExampleData.example(),
        );

        parent.addChildren([child1, child2]);

        expect(child1.key, 'child0');
        expect(child2.key, 'child1');
      });
    });

    group('isRoot', () {
      test('returns true if the node is the root node', () {
        expect(root.isRoot, isTrue);
        expect(grandpa.isRoot, isFalse);
        expect(dad.isRoot, isFalse);
        expect(me.isRoot, isFalse);
        expect(child.isRoot, isFalse);
        expect(grandchild.isRoot, isFalse);
      });
    });

    group('set data', () {
      test('allows to set the data', () {
        me.data = ExampleData({'newKey': 'newValue'});

        expect(me.data.toJson(), {'newKey': 'newValue'});
      });

      test('throws when readonly is set', () {
        me.setReadOnly(true);

        var messages = <String>[];
        try {
          me.data = ExampleData.example();
        } catch (e) {
          messages = [(e as dynamic).message as String];
        }
        expect(messages, ['Tree node "me" is readonly']);
      });
    });
  });
}
