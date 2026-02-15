// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('ChildIterator', () {
    late final ChildIterator<ExampleData> iterator;
    late final Tree parent;
    late final Tree me, brother, sister;

    setUpAll(() {
      iterator = ChildIterator.example();
      parent = iterator.parent;

      [me, brother, sister] = parent.children.toList();
    });

    group('fromTree', () {
      test('creates iterator with correct values', () {
        expect(iterator.parent, parent);
        expect(iterator.previous, isNull);
        expect(iterator.current, me);
        expect(iterator.next, brother);
        expect(iterator.i, 0);
      });
    });

    group('forward', () {
      test('moves everything forward to the next child', () {
        final iterated = iterator.forward;
        expect(iterated.parent, parent);
        expect(iterated.previous, me);
        expect(iterated.current, brother);
        expect(iterated.next, sister);
        expect(iterated.i, 1);
      });

      test('throws when end is reached', () {
        var message = <String>[];
        try {
          iterator.forward.forward.forward;
        } catch (e) {
          message = (e as dynamic).message.toString().trim().split('\n');
        }

        expect(message, ['Index 3 of "dad" exceeds bounds.']);
      });
    });

    group('backward', () {
      test('moves everything backward to the previous child', () {
        final iterated = iterator.forward.backward;
        expect(iterated.parent, parent);
        expect(iterated.previous, isNull);
        expect(iterated.current, me);
        expect(iterated.next, brother);
        expect(iterated.i, 0);
      });

      test('throws when beginning is reached', () {
        var message = <String>[];
        try {
          iterator.backward;
        } catch (e) {
          message = (e as dynamic).message.toString().trim().split('\n');
        }

        expect(message, ['Index -1 of "dad" exceeds bounds.']);
      });
    });

    group('jump', () {
      test('jumps to the specific item', () {
        final iterated = iterator.jump(2);
        expect(iterated.parent, parent);
        expect(iterated.previous, brother);
        expect(iterated.current, sister);
        expect(iterated.next, isNull);
        expect(iterated.i, 2);
      });

      test('throws when index is out of bounds', () {
        var message = <String>[];
        try {
          iterator.jump(3);
        } catch (e) {
          message = (e as dynamic).message.toString().trim().split('\n');
        }

        expect(message, ['Index 3 of "dad" exceeds bounds.']);
      });
    });

    group('i', () {
      test('returns correct index', () {
        expect(iterator.i, 0);
        expect(iterator.forward.i, 1);
        expect(iterator.forward.forward.i, 2);
      });
    });

    group('parent', () {
      test('returns the parent slot tree', () {
        expect(iterator.parent, equals(parent));
      });
    });

    group('current', () {
      test('returns the current slot tree', () {
        expect(iterator.current, me);
      });
    });

    group('previous', () {
      test('returns null when at first item', () {
        expect(iterator.previous, isNull);
      });

      test('returns previous item when not at first', () {
        expect(iterator.forward.previous, me);
      });
    });

    group('next', () {
      test('returns null when at last item', () {
        expect(iterator.forward.forward.next, isNull);
      });

      test('returns next item when not at last', () {
        expect(iterator.next, equals(brother));
      });
    });

    group('isFirst', () {
      test('returns true when previous is null', () {
        expect(iterator.isFirst, isTrue);
      });

      test('returns false when previous is not null', () {
        expect(iterator.forward.isFirst, isFalse);
      });
    });

    group('isLast', () {
      test('returns true when next is null', () {
        expect(iterator.forward.forward.isLast, isTrue);
      });

      test('returns false when next is not null', () {
        expect(iterator.isLast, isFalse);
        expect(iterator.forward.isLast, isFalse);
        expect(iterator.forward.forward.isLast, isTrue);
      });
    });
  });
}
