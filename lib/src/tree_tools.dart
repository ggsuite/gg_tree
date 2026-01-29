// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';

/// Tools for working with [Tree] instances
class TreeTools {
  /// Constructor
  const TreeTools({required this.tree});

  /// Example instance for test purposes
  factory TreeTools.example() => TreeTools(tree: JsonTree.example());

  /// The tree this instance works with
  final Tree tree;
}
