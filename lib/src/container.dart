// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';

/// A container for configuration and composition items.
abstract class Container<T extends ContainerItem> {
  /// A map assigning each container item to its hashes.
  Map<String, T> get map;

  /// A list of items in this container.
  List<T> get items;
}
