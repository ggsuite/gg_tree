// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:json_annotation/json_annotation.dart';

part 'tree.g.dart';

/// A tree of composition items reflecting the generator hierarchy
@JsonSerializable(explicitToJson: true)
class Tree {
  /// Constructor
  const Tree({
    required Map<String, dynamic> item,
    Map<String, Tree> children = const {},
  }) : _children = children,
       _item = item;

  /// Example instance for test purposes
  factory Tree.example() {
    return Tree._example();
  }

  // ...........................................................................
  /// Creates a [Tree] from a JSON map
  factory Tree.fromJson(Map<String, dynamic> json) => _$TreeFromJson(json);

  /// Converts this [Tree] to a JSON map
  Map<String, dynamic> toJson() {
    final result = _$TreeToJson(this);
    if (_children.isEmpty) {
      result.remove('children');
    }
    return result;
  }

  // ...........................................................................
  /// Returns the item belonging to the tree
  Map<String, dynamic> get item => _item;

  /// Get the children of the tree
  Map<String, Tree> get children => _children;

  // ######################
  // Private
  // ######################

  // ...........................................................................
  /// The item of this tree node
  final Map<String, dynamic> _item;

  /// Child tree items
  final Map<String, Tree> _children;

  factory Tree._example() {
    return const Tree(
      item: {'hello': 'world'},
      children: {
        'child1': Tree(item: {'child1': 'value1'}),
        'child2': Tree(
          item: {'child2': 'value2'},
          children: {
            'grandchild': Tree(item: {'grandchild': 'value3'}),
          },
        ),
      },
    );
  }
}
