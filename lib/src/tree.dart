// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/src/tree_data.dart';
import 'package:gg_tree/src/tree_query.dart';

/// A tree of composition items reflecting the generator hierarchy

class Tree<T extends TreeData> {
  /// Constructor
  factory Tree({
    required String key,
    required Tree<T> parent,
    required T value,
    Iterable<Tree<T>> children = const [],
    String? originalKey,
  }) => Tree._(
    key: key,
    parent: parent,
    value: value,
    children: children,
    originalKey: originalKey,
  );

  // ...........................................................................
  /// Constructor for a root tree
  factory Tree.root({
    required String key,
    required T value,
    Iterable<Tree<T>> children = const [],
    String? originalKey,
  }) => Tree._(
    key: key,
    parent: null,
    value: value,
    children: children,
    originalKey: originalKey,
  );

  /// Example instance for test purposes
  static Tree<ExampleData> example({String? key}) =>
      Tree.exampleNodes(key: key).$4;

  /// Example instance for test purposes
  static (
    Tree<ExampleData> root,
    Tree<ExampleData> grandpa,
    Tree<ExampleData> dad,
    Tree<ExampleData> me,
    Tree<ExampleData> child,
    Tree<ExampleData> grandchild,
  )
  exampleNodes({String? key}) => _exampleNodes(key: key);

  // ...........................................................................
  /// Returns a string representation of this node
  @override
  String toString() => key;

  // ...........................................................................
  /// The key of this node
  String key;

  /// The original unnamed key.
  String originalKey;

  /// Returns the value of this node
  T get value => _data;

  /// Returns the value as JSON
  Json get valueJson => _data.toJson();

  // ...........................................................................
  /// Set the parent
  set parent(Tree<T>? parent) {
    _throwWhenReadonly();
    _parent?._children.remove(this);
    _parent = parent;

    if (_parent?._children.contains(this) == false) {
      _parent?._children.add(this);
    }

    _parent?._makeNodeNamesUnique();
  }

  /// Returns the parent node or null if this is the root
  Tree<T>? get parent => _parent;

  /// Returns the root node
  Tree<T> get root {
    Tree<T> current = this;
    while (current.parent != null) {
      current = current.parent!;
    }
    return current;
  }

  /// Returns a list of children
  Iterable<Tree<T>> get children => _children;

  /// Returns all children to list of children
  void addChildren(Iterable<Tree<T>> children) {
    _children.addAll(children);
    _makeNodeNamesUnique();
  }

  /// Returns a child by its key or null if not found
  Tree<T>? childByKey(String key) {
    for (final child in _children) {
      if (child.key == key) {
        return child;
      }
    }
    return null;
  }

  // ...........................................................................
  /// Finds a child node by path segments
  Tree<T>? relative(Iterable<String> path) => _relative(path);

  /// Finds a child node by absolute path segments from the root
  Tree<T>? absolute(Iterable<String> path) => _absolute(path);

  /// Finds a node by path segments. Starts at this node or at the root.
  Tree<T>? findNodeOrNull(String path) => _findNode(path);

  /// Finds a node by path segments. Throws when the node could not be found.
  Tree<T> findNode(String path) => _findNode(path, throwWhenNotFound: true)!;

  // ...........................................................................
  /// Returns a json value for this query
  V? getOrNull<V>(String query) => _getOrNull(query);

  /// Returns a json value for this query or null if query could not be resolved
  V get<V>(String query) => _get(query);

  /// Write a value into this node
  void set<V>(String key, V value, {bool extend = false}) {
    _throwWhenReadonly();
    _set<V>(key, value, extend: extend);
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

  // ...........................................................................
  /// Lists all objects paths of this tree
  List<String> ls({String prefix = ''}) {
    final paths = <String>[];

    _ls(paths, '');
    return prefix.isEmpty ? paths : paths.map((e) => '$prefix$e').toList();
  }

  // ######################
  // Private
  // ######################

  static (
    Tree<ExampleData> root,
    Tree<ExampleData> grandpa,
    Tree<ExampleData> dad,
    Tree<ExampleData> me,
    Tree<ExampleData> child,
    Tree<ExampleData> grandchild,
  )
  _exampleNodes({String? key}) {
    final root = Tree<ExampleData>.root(
      key: key ?? 'root',
      value: ExampleData({
        'me': 'root',
        'hiRoot': 'Hi from root.',
        'isAncestor': true,
      }),
    );

    final grandpa = Tree<ExampleData>(
      parent: root,
      key: 'grandpa',
      value: ExampleData({
        'me': 'grandpa',
        'hiGrandpa': 'Hi from grandpa.',
        'isAncestor': false,
      }),
    );

    final dad = Tree<ExampleData>(
      parent: grandpa,
      key: 'dad',
      value: ExampleData({
        'me': 'dad',
        'hiDad': 'Hi from dad.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final me = Tree<ExampleData>(
      parent: dad,
      key: 'me',
      value: ExampleData({
        'me': 'me',
        'hiMe': 'Hi from me.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final child = Tree<ExampleData>(
      parent: me,
      key: 'child',
      value: ExampleData({
        'me': 'child',
        'hiChild': 'Hi from child.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final grandchild = Tree<ExampleData>(
      parent: child,
      key: 'grandchild',
      value: ExampleData({
        'me': 'grandchild',
        'hiGrandchild': 'Hi from grandchild.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    return (root, grandpa, dad, me, child, grandchild);
  }

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
    required String? originalKey,
  }) : originalKey = originalKey ?? key,
       _data = value,
       _children = [...children] {
    _init(parent);
    _makeNodeNamesUnique();
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
    json['originalKey'] = tree.originalKey;
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
      originalKey: json['originalKey'] as String,
      parent: null,
      value: _data.fromJson(json['_data'] as Json) as T,
      children: ch,
    );
  }

  // ...........................................................................
  V? _getOrNull<V>(String query, {bool throwWhenNotFound = false}) {
    final q = TreeQuery(query);

    // Collect all nodes the query needs to be applied to
    late final Iterable<Tree<T>> nodes;
    if (q.searchToRoot) {
      nodes = ancestors(
        includeRoot: true,
        includeSelf: true,
        startAtRoot: false,
      );
    } else {
      final node = _findNode(q.node);
      nodes = node == null ? [] : [node];
    }

    // Iterate all nodes and apply the query
    for (final node in nodes) {
      final value = node.valueJson.getOrNull<V>(q.data);
      if (value != null) {
        return value;
      }
    }

    return null;
  }

  // ...........................................................................
  V _get<V>(String query) {
    final result = _getOrNull<V>(query, throwWhenNotFound: true) as V;
    return result;
  }

  // ...........................................................................
  void _set<V>(String query, V value, {bool extend = false}) {
    final q = TreeQuery(query);
    final node = findNode(q.node);
    final newJson = node.valueJson.set<V>(q.data, value, extend: extend);
    node._data = node._data.fromJson(newJson) as T;
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

  // ...........................................................................
  void _ls(List<String> paths, String ownPath) {
    final path = ownPath.isEmpty ? '/' : ownPath;
    paths.add(path);

    for (final child in children) {
      child._ls(paths, '$ownPath/${child.key}');
    }
  }

  // ...........................................................................
  void _makeNodeNamesUnique() {
    if (_children.length <= 1) {
      return;
    }

    final nameCounts = <String, int>{};
    bool hasAmbigious = false;

    // Calculate the counts of all node names
    for (final node in _children) {
      var nodKey = node.originalKey;
      if (nameCounts.containsKey(nodKey)) {
        final count = nameCounts[nodKey]!;
        if (count == 1) {
          hasAmbigious = true;
        }

        nameCounts[nodKey] = count + 1;
        nodKey = '${nodKey}_$count';
      } else {
        nameCounts[nodKey] = 1;
      }
    }

    if (!hasAmbigious) {
      return;
    }

    // Rename all nodes that have duplicates
    final counts = <String, int>{};

    for (final key in nameCounts.keys) {
      counts[key] = 0;
    }

    for (var i = 0; i < _children.length; i++) {
      final node = _children[i];
      var nodKey = node.originalKey;
      if (nameCounts[nodKey]! > 1) {
        final count = counts[nodKey]!;
        counts[nodKey] = count + 1;
        nodKey = '$nodKey$count';
      }
      node.key = nodKey;
    }
  }

  // ...........................................................................
  Tree<T>? _relative(Iterable<String> path, {bool throwWhenNotFound = false}) {
    Tree<T> current = this;

    final okSegments = <String>[];

    for (final segment in path) {
      if (segment.isEmpty) {
        okSegments.add(segment);
        continue;
      }

      if (segment == '.') {
        okSegments.add(segment);
        continue;
      } else if (segment == '..') {
        final parent = current.parent;
        if (parent == null) {
          return null;
        }

        current = parent;
        okSegments.add(segment);
        continue;
      }

      final child = current.childByKey(segment);
      if (child == null) {
        if (throwWhenNotFound) {
          _throwRelativePathNotFound(path, current, okSegments);
        }
        return null;
      }

      current = child;
      okSegments.add(segment);
    }
    return current;
  }

  // ...........................................................................
  Tree<T>? _absolute(Iterable<String> path) => root.relative(path);

  // ...........................................................................
  Tree<T>? _findNode(String path, {bool throwWhenNotFound = false}) {
    if (path.isEmpty) {
      if (throwWhenNotFound) {
        throw Exception('Path is empty');
      }

      return null;
    }

    final segments = path.split('/').where((e) => e.isNotEmpty);

    final fromRoot = path.startsWith('/');

    if (fromRoot) {
      return _findNodeAbsolute(segments, throwWhenNotFound);
    } else {
      return _findNodeRelative(segments, throwWhenNotFound);
    }
  }

  // ...........................................................................
  Tree<T>? _findNodeRelative(Iterable<String> path, bool throwWhenNotFound) {
    if (path.first == '.' || path.first == '..') {
      return _relative(path, throwWhenNotFound: throwWhenNotFound);
    }

    late final Tree<T>? start;
    if (path.first == '...') {
      start = parent;
      path = path.skip(1);
      if (path.isEmpty) {
        throw Exception('Path "..." must be followed by at least one segment');
      }
    } else {
      start = this;
    }

    var current = start;
    while (current != null) {
      final result = current._relative(path);
      if (result != null) {
        return result;
      }
      current = current.parent;
    }

    return null;
  }

  // ...........................................................................
  /// Returns all ancestors of this node
  Iterable<Tree<T>> ancestors({
    bool includeSelf = false,
    bool includeRoot = true,
    bool startAtRoot = false,
  }) {
    var result = <Tree<T>>[];
    Tree<T>? current = includeSelf ? this : parent;
    while (current != null) {
      result.add(current);
      current = current.parent;
    }

    result = includeRoot ? result : result.sublist(0, result.length - 1);
    return startAtRoot ? result.toList().reversed : result;
  }

  // ...........................................................................
  Tree<T>? _findNodeAbsolute(Iterable<String> path, bool throwWhenNotFound) {
    // Get all ancestors from root to this node
    var nodes = ancestors(
      includeSelf: true,
      includeRoot: false,
      startAtRoot: true,
    );

    Iterable<String> p = [...path];

    // Return root when path is empty
    if (p.isEmpty) {
      return root;
    }

    final okSegments = <String>[];

    // Iterate through all ancestors
    for (var i = 0; i < nodes.length; i++) {
      // Get current and next node
      final node = nodes.elementAt(i);
      final nextNode = nodes.elementAtOrNull(i + 1);
      final segment = p.first;
      final nextSegment = p.elementAtOrNull(1);

      // Check for match
      if (node.key == segment || segment == '*' || segment == '**') {
        okSegments.add(segment);

        // Jump to next search segment
        final nextSegmentMatches = nextNode?.key == nextSegment;
        p = segment == '**' && !nextSegmentMatches && nextNode != null
            ? p
            : p.skip(1);

        // If this is the last segment, return the node
        if (p.isEmpty) {
          return node;
        }

        // Continue to next ancestor
        continue;
      }
      // If no match
      else {
        // throw when not found
        if (throwWhenNotFound) {
          _throwAbsolutePathNotFound(path, node, okSegments);
        }

        // or return null
        return null;
      }
    }

    final result = nodes.last.relative(['.', ...p]);

    if (result == null && throwWhenNotFound) {
      _throwAbsolutePathNotFound(path, nodes.last, okSegments);
    }
    return result;
  }

  // ...........................................................................
  void _throwAbsolutePathNotFound(
    Iterable<String> path,
    Tree<dynamic> node,
    List<String> okSegments,
  ) {
    final prefix = okSegments.join('/');
    final possiblePaths = node.ls().map((e) => '  - /$prefix$e');

    throw Exception(
      [
        'Could not find node "/${path.join('/')}"',
        '',
        'Possible paths:',
        ...possiblePaths,
      ].join('\n'),
    );
  }

  // ...........................................................................
  void _throwRelativePathNotFound(
    Iterable<String> path,
    Tree<dynamic> node,
    List<String> okSegments,
  ) {
    final prefix = okSegments.join('/');
    final possiblePaths = node.ls().map((e) => '  - $prefix$e');

    throw Exception(
      [
        'Could not find node "${path.join('/')}"',
        '',
        'Possible paths:',
        ...possiblePaths,
      ].join('\n'),
    );
  }
}
