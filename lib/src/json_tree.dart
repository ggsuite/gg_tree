// @license
// Copyright (c) 2026 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_tree.g.dart';

/// Returns a tree of JSON objects
@JsonSerializable(explicitToJson: true)
class JsonTree implements Tree {
  /// Constructor
  const JsonTree({
    required Json item,
    Map<String, JsonTree> children = const {},
  }) : _children = children,
       _item = item;

  /// Example instance for test purposes
  factory JsonTree.example() {
    return JsonTree._example();
  }

  // ...........................................................................
  /// Creates a [JsonTree] from a JSON map
  factory JsonTree.fromJson(Json json) => _$JsonTreeFromJson(json);

  /// Converts this [JsonTree] to a JSON map
  Json toJson() {
    final result = _$JsonTreeToJson(this);
    if (_children.isEmpty) {
      result.remove('children');
    }
    return result;
  }

  // ...........................................................................
  /// Returns the item belonging to the tree
  @override
  Json get item => _item;

  /// Get the children of the tree
  @override
  Map<String, JsonTree> get children => _children;

  // ######################
  // Private
  // ######################

  // ...........................................................................
  /// The item of this tree node
  final Json _item;

  /// Child tree items
  final Map<String, JsonTree> _children;

  factory JsonTree._example() {
    return const JsonTree(
      item: {'hello': 'world'},
      children: {
        'child1': JsonTree(item: {'child1': 'value1'}),
        'child2': JsonTree(
          item: {'child2': 'value2'},
          children: {
            'grandchild': JsonTree(item: {'grandchild': 'value3'}),
          },
        ),
      },
    );
  }
}
