// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// ignore_for_file: unused_field

/// Parses a tree query
class TreeQuery {
  /// Constructor
  TreeQuery(String query) : _q = query {
    _init();
  }

  /// Example query
  factory TreeQuery.example() => TreeQuery('./x/y#a.b');

  // ...........................................................................
  /// Returns the node part of the query
  late final String node;

  // ...........................................................................
  /// Returns the data part of the query
  late final String data;

  // ...........................................................................
  /// Returns true when searching to the root
  bool get searchToRoot =>
      node.isEmpty || !(firstNodeSegment == '.' || firstNodeSegment == '..');

  /// Returns true when searching in ancestors excluding own node
  bool get searchInParentNode =>
      firstNodeSegment.isEmpty ||
      firstNodeSegment == '..' ||
      firstNodeSegment == '...' ||
      firstNodeSegment != '.';

  /// Returns true when searching in own node
  bool get searchInOwnNode => firstNodeSegment == '.' || node.isEmpty;

  /// Returns true when searching in child nodes
  bool get searchInChildNodes => node.contains(RegExp(r'[a-z]+'));

  /// Returns the node path segments
  late final Iterable<String> nodeSegments;

  /// Returns the first node path segment or empty string
  late final String firstNodeSegment = nodeSegments.isNotEmpty
      ? nodeSegments.first
      : '';

  // ######################
  // Private
  // ######################

  final String _q;

  void _init() {
    _initParts();
    _initSegments();
  }

  // ...........................................................................
  void _initParts() {
    final parts = _q.split('#');
    if (parts.length == 1) {
      throw Exception('Query $_q must only contain exactly one #.');
    } else if (parts.length == 2) {
      node = _addTrailingSlash(parts.first);
      data = _addTrailingSlash(_removeLeadingSlash(parts.last));
    } else {
      throw Exception('Query $_q must only contain one #.');
    }
  }

  // ...........................................................................
  void _initSegments() {
    nodeSegments = node
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
  }

  // ...........................................................................
  String _removeLeadingSlash(String path) {
    if (path.isNotEmpty && path[0] == '/') {
      path = path.substring(1);
    }

    return path;
  }

  // ...........................................................................
  String _addTrailingSlash(String path) {
    if (path.isNotEmpty && path[path.length - 1] != '/') {
      path = '$path/';
    }
    return path;
  }
}
