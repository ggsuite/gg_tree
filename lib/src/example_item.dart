// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_tree/gg_tree.dart';

/// An example container item
class ExampleItem extends ContainerItem {
  /// Constructor
  ExampleItem(this.hash, this.property);

  /// Factory constructor for an example item
  factory ExampleItem.example() {
    return ExampleItem('exampleHash', 'exampleProperty');
  }

  @override
  final String hash;

  @override
  final String property;

  @override
  String toString() => 'ExampleItem(hash: $hash, property: $property)';
}
