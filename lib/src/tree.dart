// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';

/// A tree of composition items reflecting the generator hierarchy
abstract class Tree {
  /// Example instance for test purposes
  factory Tree.example() => JsonTree.example();

  // ...........................................................................
  /// Returns the item belonging to the tree
  Json get item;

  /// Get the children of the tree
  Json get children;
}
