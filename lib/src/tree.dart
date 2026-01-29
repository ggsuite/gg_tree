// @license
// Copyright (c) 2025 Dr. Gabriel Gatzsche
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_direct_json/gg_direct_json.dart';
import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/src/tree_data.dart';

/// A tree of composition items reflecting the generator hierarchy
class Tree<T extends TreeData> {
  /// Constructor
  Tree({
    required this.key,
    required Tree<T> parent,
    required T value,
    Iterable<Tree<T>> children = const [],
  }) : _data = value,
       _children = [...children] {
    _throwOnInvalidKey();
    for (final child in children) {
      child.parent = this;
    }

    this.parent = parent;
  }

  // ...........................................................................
  /// Constructor for a root tree
  Tree.root({
    required this.key,
    required T value,
    Iterable<Tree<T>> children = const [],
  }) : _parent = null,
       _data = value,
       _children = [...children];

  // ...........................................................................
  /// Example instance for test purposes
  static Tree<ExampleData> example() {
    final root = Tree<ExampleData>.root(
      key: 'root',
      value: ExampleData(exampleJsonPrimitive),
    );

    final child = Tree<ExampleData>(
      key: 'child',
      parent: root,
      value: ExampleData(exampleJsonNested0),
    );

    Tree<ExampleData>(
      key: 'grandChild',
      parent: child,
      value: ExampleData(exampleJsonNested1),
    );

    return root;
  }

  // ...........................................................................
  /// The key of this node
  String key;

  /// Returns the value of this node
  T get value => _data;

  // ...........................................................................
  /// Set the parent
  set parent(Tree<T>? parent) {
    throwWhenReadonly();
    _parent?._children.remove(this);
    _parent = parent;
    _parent?._children.add(this);
  }

  /// Returns the parent node or null if this is the root
  Tree<T>? get parent => _parent;

  /// Returns a list of children
  Iterable<Tree<T>> get children => _children;

  // ...........................................................................
  /// Returns a json value for this query
  V? getOrNull<V>(String query) => _getOrNull(query);

  /// Returns a json value for this query or null if query could not be resolved
  V get<V>(String query) => _get(query);

  /// Write a value into this node
  void set<V>(String key, V value) {
    throwWhenReadonly();
    _set<V>(key, value);
  }

  // ...........................................................................
  /// Make this node read only
  void setReadOnly(bool readOnly, {bool recursive = false}) {
    _readOnly = readOnly;
    for (final child in children) {
      child.setReadOnly(true, recursive: recursive);
    }
  }

  /// Wether this tree node is readonly
  bool get readOnly => _readOnly;

  // ...........................................................................
  /// Throws an exception when this tree is readonly
  void throwWhenReadonly() {
    if (readOnly) {
      throw Exception('Tree node with key $key is readonly');
    }
  }

  /// Throws when this node's key is not valid
  void throwOnInvalidKey() => _throwOnInvalidKey();

  // ...........................................................................
  /// Converts this [JsonTree] to a JSON map
  Json toJson() => _toJson(this);

  // ######################
  // Private
  // ######################

  final List<Tree<T>> _children;

  T _data;

  Tree<T>? _parent;

  bool _readOnly = false;

  void _throwOnInvalidKey() {
    final isValid = RegExp(
      r'^[a-z][a-z0-9]*(?:[A-Z][a-z0-9]*)*$',
    ).hasMatch(key);
    if (!isValid) {
      throw Exception(
        [
          'Invalid key "$key". ',
          'Expected lowerCamelCase and not starting with a number.',
        ].join('\n'),
      );
    }
  }

  Json _toJson(Tree tree) {
    final json = Json();
    json['_value'] = tree.value.toJson();
    for (final child in tree.children) {
      json[child.key] = _toJson(child);
    }
    return json;
  }

  // ...........................................................................
  V? _getOrNull<V>(String query) {
    if (query.startsWith('.')) {
      query = query.substring(1);
      final json = _data.toJson();
      final result = DirectJson(json: json).get<V>(query);

      return result;
    }
    return null;
  }

  // ...........................................................................
  V _get<V>(String query) {
    final result = _getOrNull<V>(query);
    if (result == null) {
      throw Exception(
        ['Cannot resolve query "$query" for tree with key "$key"'].join('\n'),
      );
    }

    return result;
  }

  // ...........................................................................
  void _set<V>(String query, V value) {
    if (query == '.') {
      _data = _data.fromJson(value as Json) as T;
      return;
    } else if (query.startsWith('.')) {
      query = query.substring(1);

      final json = _data.toJson();
      DirectJson(json: json).set(query, value);
      _data = _data.fromJson(json) as T;
    } else {
      throw UnimplementedError(
        'Cannot set value for query "$query" for tree with key "$key"',
      );
    }
  }
}
