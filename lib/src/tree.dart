// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// A tree of composition items reflecting the generator hierarchy
class Tree<T extends Map<String, dynamic>> {
  /// Constructor
  const Tree({required this.item, required this.children});

  /// Example instance for test purposes
  static Tree<Map<String, dynamic>> example() {
    return Tree._example();
  }

  // ...........................................................................

  /// The item of this tree node
  final T item;

  /// Child tree items
  final List<Tree<T>> children;

  // ######################
  // Private
  // ######################

  static Tree<Map<String, dynamic>> _example() {
    return const Tree(
      item: {'hello': 'world'},
      children: [
        Tree(item: {'child1': 'value1'}, children: []),
        Tree(
          item: {'child2': 'value2'},
          children: [
            Tree(item: {'grandchild': 'value3'}, children: []),
          ],
        ),
      ],
    );
  }
}
