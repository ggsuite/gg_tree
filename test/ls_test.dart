// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_golden/gg_golden.dart';
import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

// .............................................................................
void main() {
  group('TreeLs', () {
    late Tree<ExampleData> root;
    late Tree<ExampleData> me;
    late Tree<ExampleData> grandchild;

    setUp(() {
      (root, _, _, me, _, _, _, grandchild) = Tree.exampleNodes();
    });

    group('ls, lsProps', () {
      group('with showDataPaths', () {
        group('true', () {
          group('withProps false', () {
            group('return all paths of the tree', () {
              test('for node root', () async {
                final ls = root.lsProps();
                await writeGolden('root_ls.json', ls);

                expect(
                  ls,
                  containsAll([
                    '.#node/path',
                    '.#node/pathSimple',
                    '.#node/isRoot',
                    './grandpa#.',
                    './grandpa#me',
                    './grandpa#hiGrandpa',
                    './grandpa#isAncestor',
                    './grandpa#node/.',
                    './grandpa#node/key',
                    './grandpa#node/originalKey',
                    './grandpa#node/isReadOnly',
                    './grandpa#node/childCount',
                  ]),
                );
              });

              test('for node me', () async {
                final meLs = me.lsProps();
                await writeGolden('me_ls.json', meLs);

                expect(meLs, [
                  '.#.',
                  '.#me',
                  '.#hiMe',
                  '.#isAncestor',
                  '.#nums',
                  '.#nums/string',
                  '.#nums/int',
                  '.#nums/double',
                  '.#nums/true',
                  '.#nums/false',
                  '.#nums/null',
                  '.#node/.',
                  '.#node/key',
                  '.#node/originalKey',
                  '.#node/isReadOnly',
                  '.#node/childCount',
                  '.#node/siblingsCount',
                  '.#node/index',
                  '.#node/reverseIndex',
                  '.#node/path',
                  '.#node/pathSimple',
                  '.#node/isRoot',
                  './child#.',
                  './child#me',
                  './child#hiChild',
                  './child#isAncestor',
                  './child#nums',
                  './child#nums/string',
                  './child#nums/int',
                  './child#nums/double',
                  './child#nums/true',
                  './child#nums/false',
                  './child#nums/null',
                  './child#node/.',
                  './child#node/key',
                  './child#node/originalKey',
                  './child#node/isReadOnly',
                  './child#node/childCount',
                  './child#node/siblingsCount',
                  './child#node/index',
                  './child#node/reverseIndex',
                  './child#node/path',
                  './child#node/pathSimple',
                  './child#node/isRoot',
                  './child/grandchild#.',
                  './child/grandchild#me',
                  './child/grandchild#hiGrandchild',
                  './child/grandchild#isAncestor',
                  './child/grandchild#nums',
                  './child/grandchild#nums/string',
                  './child/grandchild#nums/int',
                  './child/grandchild#nums/double',
                  './child/grandchild#nums/true',
                  './child/grandchild#nums/false',
                  './child/grandchild#nums/null',
                  './child/grandchild#node/.',
                  './child/grandchild#node/key',
                  './child/grandchild#node/originalKey',
                  './child/grandchild#node/isReadOnly',
                  './child/grandchild#node/childCount',
                  './child/grandchild#node/siblingsCount',
                  './child/grandchild#node/index',
                  './child/grandchild#node/reverseIndex',
                  './child/grandchild#node/path',
                  './child/grandchild#node/pathSimple',
                  './child/grandchild#node/isRoot',
                ]);
              });
            });
          });

          group('withValues true', () {
            group('adds also values of the properties', () {
              test('for node root', () async {
                final ls = root.lsProps(withValues: true);
                await writeGolden('root_ls_with_props.json', ls);

                expect(
                  ls.where((element) => element.contains('Hi ')),
                  containsAll([
                    '.#hiRoot = Hi from root.',
                    './grandpa#hiGrandpa = Hi from grandpa.',
                    './grandpa/dad#hiDad = Hi from dad.',
                    './grandpa/dad/me#hiMe = Hi from me.',
                    './grandpa/dad/me/child#hiChild = Hi from child.',
                    './grandpa/dad/me/child/grandchild#hiGrandchild = Hi from grandchild.',
                    './grandpa/dad/brother#hiBrother = Hi from brother.',
                    './grandpa/dad/sister#hiSister = Hi from sister.',
                  ]),
                );
              });
            });

            group('and whereProp given', () {
              test('allows to filter for keys', () {
                final ls = root.lsProps(
                  withValues: true,
                  whereProp: ({key, path, value}) {
                    return key?.endsWith('er') == true;
                  },
                );

                expect(ls, [
                  './grandpa/dad/brother#hiBrother = Hi from brother.',
                  './grandpa/dad/sister#hiSister = Hi from sister.',
                ]);
              });

              test('allows to filter for values', () {
                final ls = root.lsProps(
                  withValues: true,
                  whereProp: ({key, path, value}) {
                    return value is String && value.contains('sister') == true;
                  },
                );

                expect(ls, [
                  './grandpa/dad/sister#me = sister',
                  './grandpa/dad/sister#hiSister = Hi from sister.',
                  './grandpa/dad/sister#node/key = sister',
                  './grandpa/dad/sister#node/originalKey = sister',
                  './grandpa/dad/sister#node/path = /grandpa/dad/sister',
                  './grandpa/dad/sister#node/pathSimple = /grandpa/dad/sister',
                ]);
              });
            });

            group('and alsoCmoplexValues given', () {
              test('prints also complex values', () {
                final ls = grandchild.lsProps(
                  alsoComplexValues: true,
                  whereProp: ({key, path, value}) => isComplexJsonValue(value),
                );
                expect(ls, [
                  '.#. = {me: grandchild, hiGrandchild: Hi from grandchild., '
                      'isAncestor: false, nums: {string: Hello, World, int: 42,'
                      ' double: 3.14159, true: true, false: false, null: '
                      'null}}',
                  '.#nums',
                  '.#node/. = {key: grandchild, originalKey: grandchild, '
                      'isReadOnly: false, childCount: 0, siblingsCount: 1, '
                      'index: 0, reverseIndex: 0, path: '
                      '/grandpa/dad/me/child/grandchild, pathSimple: '
                      '/grandpa/dad/me/child/grandchild, isRoot: false}',
                ]);
              });
            });
          });
        });

        group('false', () {
          test('shows only the node paths', () async {
            final ls = root.ls(showProps: false);
            await writeGolden('root_ls_without_data_paths.json', ls);

            expect(
              ls,
              containsAll([
                '.',
                './grandpa',
                './grandpa/dad',
                './grandpa/dad/me',
                './grandpa/dad/me/child',
                './grandpa/dad/me/child/grandchild',
                './grandpa/dad/brother',
                './grandpa/dad/sister',
              ]),
            );

            final meLs = me.ls(showProps: false);
            await writeGolden('me_ls.json', meLs);

            expect(meLs, ['.', './child', './child/grandchild']);
          });
        });
      });

      group('with where', () {
        test('returns all paths matching the given condition', () {
          expect(
            root.ls(
              where: (node) => node.key.startsWith('g'),
              showProps: false,
            ),
            ['./grandpa', './grandpa/dad/me/child/grandchild'],
          );

          expect(
            me.ls(where: (node) => node.key.contains('h'), showProps: false),
            ['./child', './child/grandchild'],
          );
        });
      });

      group('with format', () {
        group('TreeLsFormat.paths (default)', () {
          test('returns the node paths', () {
            expect(me.ls(format: TreeLsFormat.paths), me.ls());
            expect(me.ls(format: TreeLsFormat.paths), [
              '.',
              './child',
              './child/grandchild',
            ]);
          });
        });

        group('TreeLsFormat.txtTree', () {
          test('returns the tree as an ASCII tree', () async {
            final txtTree = root.ls(format: TreeLsFormat.txtTree);
            await writeGolden('root_ls_txt_tree.txt', txtTree.join('\n'));

            expect(root.ls(format: TreeLsFormat.txtTree), [
              'root',
              '└── grandpa',
              '    └── dad',
              '        ├── me',
              '        │   └── child',
              '        │       └── grandchild',
              '        ├── brother',
              '        └── sister',
            ]);

            expect(me.ls(format: TreeLsFormat.txtTree), [
              'me',
              '└── child',
              '    └── grandchild',
            ]);
          });
        });

        group('TreeLsFormat.markdown', () {
          test('returns the tree as an indented markdown list', () async {
            final markdown = root.ls(format: TreeLsFormat.markdown);
            await writeGolden('root_ls_markdown.md', markdown.join('\n'));

            expect(root.ls(format: TreeLsFormat.markdown), [
              '- root',
              '  - grandpa',
              '    - dad',
              '      - me',
              '        - child',
              '          - grandchild',
              '      - brother',
              '      - sister',
            ]);

            expect(me.ls(format: TreeLsFormat.markdown), [
              '- me',
              '  - child',
              '    - grandchild',
            ]);
          });
        });

        group('with withValues true', () {
          test(
            'renders the json data as a sub-tree for every format',
            () async {
              // paths
              final paths = root.ls(
                showProps: true,
                withValues: true,
                alsoComplexValues: true,
              );
              await writeGolden('root_ls_with_values.json', paths);
              expect(paths, contains('.#node/key = root'));
              expect(paths, contains('./grandpa#me = grandpa'));

              // txtTree - the data is expanded into the tree
              final txtTree = root.ls(
                format: TreeLsFormat.txtTree,
                withValues: true,
              );
              await writeGolden(
                'root_ls_txt_tree_with_values.txt',
                txtTree.join('\n'),
              );
              expect(txtTree.first, 'root');
              // root's own data values appear as direct children, the data
              // root nodes are prefixed with `#` and string values are quoted
              expect(txtTree, contains('├── #me = "root"'));
              expect(txtTree, contains('├── #hiRoot = "Hi from root."'));
              // nested json (nums) is expanded recursively and is not prefixed;
              // only string values are wrapped in quotes
              expect(txtTree, contains(endsWith('└── null = null')));
              expect(txtTree, contains(endsWith('├── int = 42')));
              expect(
                txtTree,
                contains(endsWith('├── string = "Hello, World"')),
              );

              // markdown
              final markdown = root.ls(
                format: TreeLsFormat.markdown,
                withValues: true,
              );
              await writeGolden(
                'root_ls_markdown_with_values.md',
                markdown.join('\n'),
              );
              expect(markdown.first, '- root');
              expect(markdown, contains('  - #me = "root"'));
              expect(markdown, contains(endsWith('- string = "Hello, World"')));
            },
          );
        });

        group('with list values in the data', () {
          test('renders list items as a sub-tree', () {
            final tree = Tree<Json>(
              key: 'root',
              data: {
                'tags': ['a', 'b'],
              },
            );

            // txtTree exercises the list branch of the last-entry detection
            expect(tree.ls(format: TreeLsFormat.txtTree, withValues: true), [
              'root',
              '└── #tags',
              '    ├── 0 = "a"',
              '    └── 1 = "b"',
            ]);

            expect(tree.ls(format: TreeLsFormat.markdown, withValues: true), [
              '- root',
              '  - #tags',
              '    - 0 = "a"',
              '    - 1 = "b"',
            ]);
          });
        });
      });
    });
  });
}
