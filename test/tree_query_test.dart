// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('TreeQuery', () {
    group('example()', () {
      test('creates an example object', () {
        expect(TreeQuery.example().node, './x/y/');
      });
    });

    group('constructor', () {
      group('throws', () {
        test('when query contains more then one #', () {
          var message = <String>[];
          try {
            TreeQuery('a#b#c');
          } catch (e) {
            message = (e as dynamic).message.toString().trim().split('\n');
          }

          expect(message, ['Query a#b#c must only contain one #.']);
        });

        group('when query does not contain a #', () {
          test('the empty string when no json data part is given', () {
            var message = <String>[];
            try {
              TreeQuery('./a/c');
            } catch (e) {
              message = (e as dynamic).message.toString().trim().split('\n');
            }

            expect(message, ['Query ./a/c must only contain exactly one #.']);
          });
        });
      });
    });

    group('node', () {
      group('returns', () {
        test('an empty string when no node is given', () {
          expect(TreeQuery('#a/b/c').node, '');
        });
        test('the path part before the route', () {
          expect(TreeQuery('x/y/z#a/b/c').node, 'x/y/z/');
        });
      });

      group('add a trailing slash when not present', () {
        test('when node path is not ./, ../ or .../', () {
          expect(TreeQuery('x/y/z#a/b/c').node, 'x/y/z/');
          expect(TreeQuery('.#a/b/c').node, './');
          expect(TreeQuery('..#a/b/c').node, '../');
          expect(TreeQuery('...#a/b/c').node, '.../');
        });
      });

      test('returns not the trailing slash', () {
        expect(TreeQuery('/x/y/z#a/b/c').node, '/x/y/z/');
      });
    });

    group('data', () {
      group('returns the data part', () {
        test('when no node part is given', () {
          expect(TreeQuery('#a/c').data, 'a/c/');
        });

        test('when node and data part is given', () {
          expect(TreeQuery('x/y#a/c/').data, 'a/c/');
        });
      });

      test('removes leading and trailing slashes from data part', () {
        expect(TreeQuery('#/a/b/c/').data, 'a/b/c/');
      });
    });

    group('nodePathSegments', () {
      test('returns the node path segments', () {
        expect(TreeQuery('a/b/c/d/e#x/y/z').nodeSegments, [
          'a',
          'b',
          'c',
          'd',
          'e',
        ]);

        expect(TreeQuery('./a/b/c/d/e#x/y/z').nodeSegments, [
          '.',
          'a',
          'b',
          'c',
          'd',
          'e',
        ]);

        expect(TreeQuery('../a/b/c/d/e#x/y/z').nodeSegments, [
          '..',
          'a',
          'b',
          'c',
          'd',
          'e',
        ]);

        expect(TreeQuery('.../a/b/c/d/e#x/y/z').nodeSegments, [
          '...',
          'a',
          'b',
          'c',
          'd',
          'e',
        ]);
      });
    });

    group('searchInOwnNode', () {
      group('returns true', () {
        test('when node is empty', () {
          expect(TreeQuery('#d/e/f').searchInOwnNode, isTrue);
        });

        test('when node is ./', () {
          expect(TreeQuery('./#d/e/f').searchInOwnNode, isTrue);
        });
      });

      group('returns false', () {
        test('when node is ../', () {
          expect(TreeQuery('../#d/e/f').searchInOwnNode, isFalse);
        });

        test('when node is .../', () {
          expect(TreeQuery('.../#d/e/f').searchInOwnNode, isFalse);
        });

        test('when node is x/y/z/', () {
          expect(TreeQuery('x/y/z/#d/e/f').searchInOwnNode, isFalse);
        });
      });
    });

    group('searchInParentNode', () {
      group('returns true', () {
        test('when node is ""', () {
          expect(TreeQuery('#d/e/f').searchInParentNode, isTrue);
        });

        test('when node is ../', () {
          expect(TreeQuery('../#d/e/f').searchInParentNode, isTrue);
        });

        test('when node is .../', () {
          expect(TreeQuery('.../#d/e/f').searchInParentNode, isTrue);
        });

        test('when node is ../x/y/z/', () {
          expect(TreeQuery('../x/y/z/#d/e/f').searchInParentNode, isTrue);
        });

        test('when node is x/y/z/', () {
          expect(TreeQuery('x/y/z/#d/e/f').searchInParentNode, isTrue);
        });
      });

      group('returns false', () {
        test('when node is ./', () {
          expect(TreeQuery('./#d/e/f').searchInParentNode, isFalse);
        });
      });
    });

    group('searchInChildNodes', () {
      group('returns true when', () {
        test('node contains a path', () {
          expect(TreeQuery('a/b/c/#d/e/f').searchInChildNodes, isTrue);
          expect(TreeQuery('./a/b/c/#d/e/f').searchInChildNodes, isTrue);
          expect(TreeQuery('../a/b/c/#d/e/f').searchInChildNodes, isTrue);
        });
      });

      group('returns false when', () {
        test('node is empty', () {
          expect(TreeQuery('#d/e/f').searchInChildNodes, isFalse);
        });

        test('node is ./', () {
          expect(TreeQuery('./#d/e/f').searchInChildNodes, isFalse);
        });

        test('node is ../', () {
          expect(TreeQuery('../#d/e/f').searchInChildNodes, isFalse);
        });

        test('node is .../', () {
          expect(TreeQuery('.../#d/e/f').searchInChildNodes, isFalse);
        });
      });
    });

    group('searchToRoot', () {
      test('returns true if query does not start with . or ..', () {
        expect(TreeQuery('./x/y/z#').searchToRoot, isFalse);
        expect(TreeQuery('../x/y/z#').searchToRoot, isFalse);
        expect(TreeQuery('.../x/y/z#').searchToRoot, isTrue);
        expect(TreeQuery('x/y/z#').searchToRoot, isTrue);
      });
    });
  });
}
