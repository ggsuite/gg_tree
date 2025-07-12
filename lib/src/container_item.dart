// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// Base class for items of a composition or configuration.
abstract class ContainerItem {
  /// The hash of the item
  abstract final String hash;

  /// The name of the item this item is inheriting from.
  abstract final String property;
}
