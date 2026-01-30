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
  factory Tree({
    required String key,
    required Tree<T> parent,
    required T value,
    Iterable<Tree<T>> children = const [],
  }) => Tree._(key: key, parent: parent, value: value, children: children);

  // ...........................................................................
  /// Constructor for a root tree
  factory Tree.root({
    required String key,
    required T value,
    Iterable<Tree<T>> children = const [],
  }) => Tree._(key: key, parent: null, value: value, children: children);

  // ...........................................................................
  /// Example instance for test purposes
  static Tree<ExampleData> example({String? key}) {
    final root = Tree<ExampleData>.root(
      key: key ?? 'root',
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
    _throwWhenReadonly();
    _parent?._children.remove(this);
    _parent = parent;

    if (_parent?._children.contains(this) == false) {
      _parent?._children.add(this);
    }
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
    _throwWhenReadonly();
    _set<V>(key, value);
  }

  // ...........................................................................
  /// Make this node read only
  void setReadOnly(bool readOnly, {bool recursive = false}) {
    _isReadOnly = readOnly;
    if (recursive) {
      for (final child in children) {
        child.setReadOnly(true, recursive: recursive);
      }
    }
  }

  /// Wether this tree node is readonly
  bool get isReadOnly => _isReadOnly;

  // ...........................................................................
  /// Converts this [JsonTree] to a JSON map
  Json toJson() => _toJson(this);

  /// Creates a [JsonTree] from a JSON map
  Tree<T> fromJson(Json json) => _fromJson(json);

  // ...........................................................................
  /// Creates a deep copy of this tree
  Tree<T> deepCopy() => _deepCopy(this);

  // ######################
  // Private
  // ######################

  // ...........................................................................
  final List<Tree<T>> _children;

  T _data;

  Tree<T>? _parent;

  bool _isReadOnly = false;

  // ...........................................................................
  Tree._({
    required this.key,
    required Tree<T>? parent,
    required T value,
    Iterable<Tree<T>> children = const [],
  }) : _data = value,
       _children = [...children] {
    _init(parent);
  }

  // ...........................................................................
  void _init(Tree<T>? parent) {
    throwIfNotValidJsonKey(key);
    _throwOnForbiddenKey();
    for (final child in [...children]) {
      child.parent = this;
    }
    this.parent = parent;
  }

  // ...........................................................................
  void _throwOnForbiddenKey() {
    if (key.startsWith('_')) {
      throw Exception('Key "$key" must not start with _');
    }
  }

  // ...........................................................................
  Json _toJson(Tree tree) {
    final json = Json();
    json['key'] = tree.key;
    json['isReadOnly'] = tree.isReadOnly;
    json['_data'] = tree.value.toJson();

    final childrenJson = <Json>[];
    for (final child in tree.children) {
      childrenJson.add(_toJson(child));
    }
    json['_children'] = childrenJson;
    return json;
  }

  // ...........................................................................
  Tree<T> _fromJson(Json json) {
    final ch = <Tree<T>>[];
    for (final childJson in (json['_children'] as List).cast<Json>()) {
      ch.add(_fromJson(childJson));
    }

    return Tree._(
      key: json['key'] as String,
      parent: null,
      value: _data.fromJson(json['_data'] as Json) as T,
      children: ch,
    );
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
      // coverage:ignore-start
      throw UnimplementedError(
        'Cannot set value for query "$query" for tree with key "$key"',
      );
      // coverage:ignore-end
    }
  }

  // ...........................................................................
  /// Throws an exception when this tree is readonly
  void _throwWhenReadonly() {
    if (isReadOnly) {
      throw Exception('Tree node "$key" is readonly');
    }
  }

  // ...........................................................................
  Tree<T> _deepCopy(Tree<T> tree) => fromJson(toJson());
}
