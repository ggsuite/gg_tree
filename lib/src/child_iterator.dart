// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';

/// Determines if a layout needs a structural shelf.
class ChildIterator<T extends TreeData> {
  // ...........................................................................
  /// Returns the class from a slot tree
  factory ChildIterator({required Tree<T> slotTree, required int i}) {
    if (i < 0 || i >= slotTree.children.length) {
      throw Exception('Index $i of "${slotTree.key}" exceeds bounds.');
    }

    final current = slotTree.children.elementAt(i);
    final previous = i > 0 ? slotTree.children.elementAt(i - 1) : null;
    final next = slotTree.children.elementAtOrNull(i + 1);

    return ChildIterator._(
      parent: slotTree,
      i: i,
      current: current,
      next: next,
      previous: previous,
    );
  }

  // ...........................................................................
  /// Example iterator for test purposes
  static ChildIterator<ExampleData> example() =>
      ChildIterator(slotTree: Tree.example().parent!, i: 0);

  // ...........................................................................
  /// Jumps to the next item
  ChildIterator<T> get forward => jump(i + 1);

  /// Jumps to the previous item
  ChildIterator<T> get backward => jump(i - 1);

  /// Jumps to the specific item
  ChildIterator<T> jump(int i) => ChildIterator(slotTree: parent, i: i);

  // ...........................................................................
  /// The index of the current item
  final int i;

  /// The parent item
  final Tree<T> parent;

  /// The previous item
  final Tree<T>? previous;

  /// The current item
  final Tree<T> current;

  /// The next item
  final Tree<T>? next;

  // ...........................................................................
  /// Returns true if item is the last item
  bool get isLast => next == null;

  /// Returns true if item is the first item
  bool get isFirst => previous == null;

  // ######################
  // Private
  // ######################

  /// Constructor
  const ChildIterator._({
    required this.parent,
    required this.previous,
    required this.current,
    required this.next,
    required this.i,
  });
}
