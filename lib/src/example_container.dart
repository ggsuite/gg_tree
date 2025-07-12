// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';

/// An example container for test purposes
class ExampleContainer extends Container<ExampleItem> {
  /// Constructor
  ExampleContainer();

  /// Returns an example
  factory ExampleContainer.example() {
    final container = ExampleContainer();
    container.add(ExampleItem.example());
    return container;
  }

  /// Offers the items for each hash
  @override
  Map<String, ExampleItem> get map => _map;

  /// Returns the items in this container
  @override
  List<ExampleItem> get items => _items;

  /// Adds an item to the container
  void add(ExampleItem item) {
    _map[item.hash] = item;
    _items.add(item);
  }

  // ######################
  // Private
  // ######################

  final Map<String, ExampleItem> _map = {};
  final List<ExampleItem> _items = [];
}
