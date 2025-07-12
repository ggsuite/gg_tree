// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json_hash/gg_json_hash.dart';
import 'package:gg_tree/gg_tree.dart';

/// A tree of composition items reflecting the generator hierarchy
class Tree<T extends ContainerItem> {
  /// Constructor
  const Tree({required this.item, required this.children});

  /// Turns the items of an composition into an composition tree
  factory Tree.fromContainer(Container<T> container) =>
      Tree._fromContainer(container);

  /// Example instance for test purposes
  static Tree<ExampleItem> example() {
    return Tree._example();
  }

  // ...........................................................................

  /// The item of this tree node
  final T item;

  /// Child tree items
  final List<Tree<T>> children;

  // ...........................................................................
  /// Returns a hash representing the complete tree
  String get hash {
    final hash =
        hip({
              'own': item.hash,
              'children': children.map((e) => e.hash).toList(),
            })['_hash']
            as String;

    return hash;
  }

  // ######################
  // Private
  // ######################

  static Tree<ExampleItem> _example() {
    return Tree._fromContainer(ExampleContainer.example());
  }

  factory Tree._fromContainer(Container<T> container) {
    final map = container.map;

    // Create a map, assigning the child items to each hash
    // Create a map, assigning the parent items to each hash
    // Estimate the root items
    final parentMap = <String, List<String>>{};
    final childrenMap = <String, List<String>>{};
    final roots = <String>[];

    final items = container.items;
    for (final item in items) {
      final itemHash = item.hash;
      final parentHash = item.property;

      if (parentHash.isEmpty) {
        roots.add(itemHash);
      } else {
        (childrenMap[parentHash] ??= []).add(itemHash);
        (parentMap[itemHash] ??= []).add(parentHash);
      }
    }

    // Throw an exception when more than one root is contained in the container
    if (roots.length > 1) {
      throw ArgumentError(
        [
          'Container contains more than one root item:',
          ...roots.map((e) => '  - $e'),
        ].join('\n'),
      );
    }

    if (roots.isEmpty) {
      throw ArgumentError('Container does not contain a root item.');
    }

    // Start from the root and recursively build the tree
    final result = Tree<T>._buildTree(roots.first, map, childrenMap);
    return result;
  }

  factory Tree._buildTree(
    String hash,
    Map<String, T> map,
    Map<String, List<String>> childrenMap,
  ) {
    final item = map[hash] as T;
    final childrenHashes = childrenMap[hash] ?? [];
    final childrenTrees = <Tree<T>>[];
    for (final childHash in childrenHashes) {
      childrenTrees.add(Tree<T>._buildTree(childHash, map, childrenMap));
    }
    return Tree<T>(item: item, children: childrenTrees);
  }
}
