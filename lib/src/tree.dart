// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:async';

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';

part 'ls.dart';

const _isValidJsonKey = isValidJsonKey;

/// A tree of composition items reflecting the generator hierarchy
class Tree<T extends Json> {
  // ...........................................................................
  /// The base constructor used by the factories
  Tree({
    required String key,
    Tree<T>? parent,
    required T data,
    Iterable<Tree<T>> children = const [],
    String? originalKey,
    this.isValidJsonKey = _isValidJsonKey,
    P Function<P>(Json)? parse,
  }) : originalKey = originalKey ?? key,
       _key = key,
       _data = data,
       _children = [...children],
       _parent = parent,
       _parse = parse {
    _init(parent);
    _makeKeysUnique();
  }

  /// Example instance for test purposes
  static Tree<ExampleData> example({String? key}) =>
      Tree.exampleNodes(key: key).$4;

  /// Example instance for test purposes
  static (
    Tree<ExampleData> root,
    Tree<ExampleData> grandpa,
    Tree<ExampleData> dad,
    Tree<ExampleData> me,
    Tree<ExampleData> brother,
    Tree<ExampleData> sister,
    Tree<ExampleData> child,
    Tree<ExampleData> grandchild,
  )
  exampleNodes({String? key}) => _exampleNodes(key: key);

  /// The key of the node info of the path
  static const nodeInfoKey = 'node';

  // ...........................................................................
  /// Returns a string representation of this node
  @override
  String toString() => key;

  // ...........................................................................
  /// The key of this node
  String get key => _key;

  /// Sets the key of this node
  set key(String value) {
    _throwWhenReadonly();
    _throwIfNotValidJsonKey(value);
    _key = value;
    originalKey = value;

    // Also bump here: with a null or unchanged parent no _makeKeysUnique
    // call would invalidate the structure caches for the new key.
    _structureEpoch++;

    parent?._makeKeysUnique();
  }

  /// Function to validate json keys
  final bool Function(String key) isValidJsonKey;

  /// The original unnamed key.
  String originalKey;

  /// Returns true if this node is the root
  bool get isRoot => parent == null;

  /// Returns the value of this node
  T get data => _data;

  /// Parses the json data
  P parsed<P>() => _parsed();

  /// Sets the data
  set data(T value) {
    _throwWhenReadonly();
    _data = value;
  }

  // ...........................................................................
  /// Returns the path of this node
  Iterable<String> get pathSegments => ancestors(
    includeSelf: true,
    includeRoot: false,
    startAtRoot: true,
  ).map((e) => e.key);

  /// Returns the path of this node as string
  String get path {
    if (_pathEpoch == _structureEpoch) {
      return _cachedPath!;
    }

    // The root key is not part of the path. Going through the parent's
    // path getter memoizes the whole ancestor chain in one pass.
    final p = _parent;
    final result = p == null
        ? '/'
        : p._parent == null
        ? '/$_key'
        : '${p.path}/$_key';

    _cachedPath = result;
    _pathEpoch = _structureEpoch;
    return result;
  }

  /// Returns a simple path with only /, numbers and letters
  String get pathSimple => keepOnlyLetters(path);

  /// Returns a map of all paths to their corresponding tree nodes
  Map<String, Tree<T>> pathToTreeMap({bool Function(Tree<T> slot)? where}) {
    final result = <String, Tree<T>>{};
    _pathToTreeMap('', result, where: where);
    return result;
  }

  // ...........................................................................
  /// Set the parent
  set parent(Tree<T>? parent) {
    _throwWhenReadonly();

    // Also bump here: on detach (parent = null) the old parent loses a
    // child without any _makeKeysUnique call being made.
    _structureEpoch++;

    _parent?._children.remove(this);
    _parent = parent;

    if (_parent?._children.contains(this) == false) {
      _parent?._children.add(this);
    }

    _parent?._makeKeysUnique();
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

  // ...........................................................................
  /// Returns a list of children
  Iterable<Tree<T>> get children => _children;

  /// Returns all children to list of children
  void addChildren(Iterable<Tree<T>> children) {
    try {
      // The epoch is bumped once per attached child, not only at the end:
      // a lazy [children] iterable can run user code between two moves and
      // that code must not see stale caches.
      for (final child in children) {
        child._throwWhenReadonly();

        // Re-adding an existing child moves it to the end
        if (identical(child._parent, this)) {
          _children
            ..remove(child)
            ..add(child);
          _structureEpoch++;
          continue;
        }

        child._parent?._children.remove(child);
        child._parent = this;
        _children.add(child);
        _structureEpoch++;
      }
    } finally {
      // Also when a child throws mid-batch, the keys of the children
      // attached before must be made unique.
      _makeKeysUnique();
    }
  }

  /// Returns a child by its key or null if not found
  Tree<T>? childByKey(String key) {
    final epoch = _structureEpoch;
    if (_childByKeyEpoch == epoch) {
      return _childByKeyMap![key];
    }

    // First lookup after a structure change: a plain scan costs the same
    // as the previous implementation and avoids an O(n) map rebuild per
    // lookup in loops that alternate mutations and lookups.
    if (_childByKeyProbeEpoch != epoch) {
      _childByKeyProbeEpoch = epoch;
      for (final child in _children) {
        if (child._key == key) {
          return child;
        }
      }
      return null;
    }

    // Second lookup in the same epoch: build the map, further lookups
    // are O(1). Duplicate current keys are legal (only originalKeys are
    // made unique). Filling in reverse order lets earlier children
    // overwrite later ones, preserving the first-occurrence-wins
    // semantics of the linear scan.
    final map = (_childByKeyMap ??= <String, Tree<T>>{})..clear();
    final children = _children;
    for (var i = children.length - 1; i >= 0; i--) {
      final child = children[i];
      map[child._key] = child;
    }
    _childByKeyEpoch = epoch;
    return map[key];
  }

  /// Returns true if a child with the given key exists
  bool hasChildWithKey(String key) => childByKey(key) != null;

  /// Returns a child iterator for the children of this node
  ChildIterator<T> get childIterator => ChildIterator(tree: this, i: 0);

  // ...........................................................................
  /// Returns the child node by path or null if not found
  Tree<T>? childByPathOrNull(String path) =>
      _childByPath(path, throwWhenNotFound: false);

  /// Returns the child nod by path or throws if not found
  Tree<T> childByPath(String path) =>
      _childByPath(path, throwWhenNotFound: true)!;

  /// Finds a child node by path segments
  Tree<T>? relative(Iterable<String> path) => _relative(path);

  /// Finds a child node by absolute path segments from the root
  Tree<T>? absolute(Iterable<String> path) => _absolute(path);

  /// Finds a node by path segments. Starts at this node or at the root.
  Tree<T>? findNodeOrNull(String path) => _findNode(path);

  /// Finds a node by path segments. Throws when the node could not be found.
  Tree<T> findNode(String path) => _findNode(path, throwWhenNotFound: true)!;

  /// Returns the next sibling of this node, or null if there is none
  Tree<T>? get nextSibling => _nextSibling;

  /// Returns the previous sibling of this node, or null if there is none
  Tree<T>? get previousSibling => _previousSibling;

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

  /// Remove a value from this node
  void remove(String key) {
    _throwWhenReadonly();
    _remove(key);
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

  /// Set node readonly
  set isReadOnly(bool value) => setReadOnly(value);

  /// Wether this tree node is readonly
  bool get isReadOnly => _isReadOnly;

  // ...........................................................................
  /// Converts this [JsonTree] to a JSON map
  Json toJson() => _toJson(this);

  /// Creates a [JsonTree] from a JSON map
  factory Tree.fromJson(Json json) => Tree._fromJson(json);

  // ...........................................................................
  /// Creates a deep copy of this tree
  Tree<T> deepCopy({bool Function(Tree<T>)? where}) => _deepCopy(this, where);

  // ...........................................................................
  /// Creates a shallow copy of this tree with optional field overrides.
  /// Does not copy children
  Tree<T> flatCopyWith({
    String? key,
    Tree<T>? parent,
    T? data,
    Iterable<Tree<T>>? children,
    String? originalKey,
  }) => Tree(
    key: key ?? this.key,
    parent: parent,
    data: data ?? this.data.deepCopy() as T,
    children: children?.map((e) => e.flatCopyWith()).toList() ?? [],
    originalKey: originalKey ?? this.originalKey,
    isValidJsonKey: isValidJsonKey,
  );

  // ...........................................................................
  /// Lists all objects paths of this tree.
  ///
  /// Use [format] to render the tree as [TreeLsFormat.paths] (default),
  /// [TreeLsFormat.txtTree] or [TreeLsFormat.markdown]. The implementation
  /// lives in the private `_TreeLs` extension in `ls.dart`.
  List<String> ls({
    String prefix = '',
    bool Function(Tree<T> node)? where,
    bool showProps = false,
    bool withValues = false,
    bool alsoComplexValues = false,
    WhereProp? whereProp,
    TreeLsFormat format = TreeLsFormat.paths,
  }) => lsPaths(
    prefix: prefix,
    where: where,
    showProps: showProps,
    withValues: withValues,
    alsoComplexValues: alsoComplexValues,
    whereProp: whereProp,
    format: format,
  );

  // ...........................................................................
  /// Shows all nodes together with properties
  List<String> lsProps({
    String prefix = '',
    bool withValues = false,
    bool alsoComplexValues = false,
    bool Function(Tree<T> node)? where,
    WhereProp? whereProp,
  }) => ls(
    prefix: prefix,
    where: where,
    showProps: true,
    withValues: withValues,
    whereProp: whereProp,
    alsoComplexValues: alsoComplexValues,
  );

  // ...........................................................................
  /// List all nodes
  Iterable<Tree<T>> lsNodes() {
    final result = <Tree<T>>[];

    _lsNodes(result);
    return result;
  }

  // ...........................................................................
  /// List all nodes where the given condition is met
  Iterable<Tree<T>> lsNodesWhere(bool Function(Tree<T> node)? where) {
    final result = <Tree<T>>[];

    _lsNodes(result);

    return where != null ? result.where(where) : result;
  }

  // ...........................................................................
  void _lsNodes(List<Tree<T>> nodes) {
    nodes.add(this);

    for (final child in children) {
      child._lsNodes(nodes);
    }
  }

  // ...........................................................................
  /// Visits all nodes in this tree
  void visit(
    void Function(Tree<T> node) visitor, {
    bool topDown = true,
    bool Function(Tree<T> node)? where,
    bool Function(Tree<T> node)? stopAfter,
    bool Function(Tree<T> node)? stopBefore,
  }) {
    final matches = where == null || where(this);

    if (stopBefore?.call(this) == true) {
      return;
    }

    if (topDown && matches) {
      visitor(this);
    }

    if (stopAfter?.call(this) == true) {
      return;
    }

    if (_children.isNotEmpty) {
      for (final child in List<Tree<T>>.of(_children)) {
        child.visit(
          visitor,
          topDown: topDown,
          where: where,
          stopAfter: stopAfter,
          stopBefore: stopBefore,
        );
      }
    }

    if (!topDown) {
      visitor(this);
    }
  }

  // ...........................................................................
  /// Visits all nodes in this tree asynchronously
  Future<void> visitAsync(
    Future<void> Function(Tree<T> node) visitor, {
    bool topDown = true,
    bool Function(Tree<T> node)? where,
    bool Function(Tree<T> node)? stopAfter,
    bool Function(Tree<T> node)? stopBefore,
  }) async {
    final matches = where == null || where(this);

    if (stopBefore?.call(this) == true) {
      return;
    }

    if (topDown && matches) {
      await visitor(this);
    }

    if (stopAfter?.call(this) == true) {
      return;
    }

    if (_children.isNotEmpty) {
      for (final child in List<Tree<T>>.of(_children)) {
        await child.visitAsync(
          visitor,
          topDown: topDown,
          where: where,
          stopAfter: stopAfter,
          stopBefore: stopBefore,
        );
      }
    }

    if (!topDown && matches) {
      await visitor(this);
    }
  }

  // ...........................................................................
  /// Visits all nodes in this tree in the same top-down (pre-order)
  /// sequence as [visitAsync], but without per-node async overhead:
  /// the traversal only suspends when [visitor] actually returns a
  /// [Future]. When the whole traversal completes synchronously, no
  /// [Future] is allocated and `null` is returned.
  ///
  /// Like [visitAsync], each node's children are snapshotted after the
  /// node has been visited, so visitors may safely mutate the tree.
  FutureOr<void> visitFutureOr(
    FutureOr<void> Function(Tree<T> node) visitor, {
    bool Function(Tree<T> node)? where,
    bool Function(Tree<T> node)? stopAfter,
    bool Function(Tree<T> node)? stopBefore,
  }) {
    final stack = <Tree<T>>[this];
    return _visitFutureOr(stack, visitor, where, stopAfter, stopBefore);
  }

  // ######################
  // Private
  // ######################

  String _key;

  static (
    Tree<ExampleData> root,
    Tree<ExampleData> grandpa,
    Tree<ExampleData> dad,
    Tree<ExampleData> me,
    Tree<ExampleData> brother,
    Tree<ExampleData> sister,
    Tree<ExampleData> child,
    Tree<ExampleData> grandchild,
  )
  _exampleNodes({String? key}) {
    final root = Tree<ExampleData>(
      key: key ?? 'root',
      data: ExampleData({
        'me': 'root',
        'hiRoot': 'Hi from root.',
        'isAncestor': true,
      }),
    );

    final grandpa = Tree<ExampleData>(
      parent: root,
      key: 'grandpa',
      data: ExampleData({
        'me': 'grandpa',
        'hiGrandpa': 'Hi from grandpa.',
        'isAncestor': false,
      }),
    );

    final dad = Tree<ExampleData>(
      parent: grandpa,
      key: 'dad',
      data: ExampleData({
        'me': 'dad',
        'hiDad': 'Hi from dad.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final me = Tree<ExampleData>(
      parent: dad,
      key: 'me',
      data: ExampleData({
        'me': 'me',
        'hiMe': 'Hi from me.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final brother = Tree<ExampleData>(
      parent: dad,
      key: 'brother',
      data: ExampleData({
        'me': 'brother',
        'hiBrother': 'Hi from brother.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final sister = Tree<ExampleData>(
      parent: dad,
      key: 'sister',
      data: ExampleData({
        'me': 'sister',
        'hiSister': 'Hi from sister.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final child = Tree<ExampleData>(
      parent: me,
      key: 'child',
      data: ExampleData({
        'me': 'child',
        'hiChild': 'Hi from child.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    final grandchild = Tree<ExampleData>(
      parent: child,
      key: 'grandchild',
      data: ExampleData({
        'me': 'grandchild',
        'hiGrandchild': 'Hi from grandchild.',
        'isAncestor': false,
        'nums': exampleJsonPrimitive,
      }),
    );

    return (root, grandpa, dad, me, brother, sister, child, grandchild);
  }

  final P Function<P>(Json)? _parse;

  // ...........................................................................
  final List<Tree<T>> _children;

  T _data;

  Tree<T>? _parent;

  bool _isReadOnly = false;

  // ...........................................................................
  /// Monotonically increasing counter, bumped on every structural mutation
  /// (key renames, parent changes, children list changes) of ANY tree.
  ///
  /// All structure-derived caches below are stamped with this counter and
  /// are only valid while their stamp equals it. Bumping inside a mutator
  /// body is safe because no mutator reads a cached getter mid-mutation.
  /// Data mutations must NOT bump: node data is mutable in place through
  /// the [data] getter anyway, so no cache may ever depend on it.
  static int _structureEpoch = 0;

  /// Cached result of [path], valid while [_pathEpoch] is current
  String? _cachedPath;
  int _pathEpoch = -1;

  /// Cached key-to-child map, valid while [_childByKeyEpoch] is current.
  /// [_childByKeyProbeEpoch] records the first, map-less lookup per epoch.
  Map<String, Tree<T>>? _childByKeyMap;
  int _childByKeyEpoch = -1;
  int _childByKeyProbeEpoch = -1;

  /// Cached index of this node in its parent's children list, valid while
  /// [_indexEpoch] is current
  int _indexInParent = 0;
  int _indexEpoch = -1;

  /// Cached path resolutions of [_findNode] and [_childByPath], valid
  /// while [_resolveEpoch] is current. Two maps because findNode searches
  /// up the ancestor chain while childByPath strictly descends.
  Map<String, Tree<T>>? _findNodeCache;
  Map<String, Tree<T>>? _childByPathCache;
  int _resolveEpoch = -1;

  /// Maximum number of entries in a per-node resolution cache
  static const int _maxResolutionCacheLength = 128;

  // ...........................................................................
  /// Returns the index of this node within its parent's children.
  ///
  /// Callers must guarantee a non-null parent. On a stale stamp the parent
  /// re-stamps ALL children in one O(n) pass, so iterating the siblings of
  /// a wide node costs O(n) overall instead of O(n²).
  int _siblingIndex() {
    if (_indexEpoch != _structureEpoch) {
      _parent!._reindexChildren();
    }
    return _indexInParent;
  }

  /// Stamps the current index into all children
  void _reindexChildren() {
    final epoch = _structureEpoch;
    final children = _children;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];

      // After a partial constructor failure a foreign node can sit in this
      // list while still belonging to another parent. Its index within
      // that parent must not be overwritten with its position here.
      if (identical(child._parent, this)) {
        child
          .._indexInParent = i
          .._indexEpoch = epoch;
      }
    }
  }

  // ...........................................................................
  /// Clears the resolution caches when the structure changed
  void _validateResolutionCaches() {
    if (_resolveEpoch != _structureEpoch) {
      _findNodeCache?.clear();
      _childByPathCache?.clear();
      _resolveEpoch = _structureEpoch;
    }
  }

  // ...........................................................................
  /// Path strings split into segments, cached by the path string
  static final Map<String, List<String>> _segmentsCache = {};

  /// Splits [path] into segments or returns a previously cached split.
  /// The returned list must not be modified.
  static List<String> _splitPath(String path) {
    final cached = _segmentsCache[path];
    if (cached != null) {
      return cached;
    }

    final result = path
        .split('/')
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (_segmentsCache.length >= 512) {
      _segmentsCache.clear();
    }
    _segmentsCache[path] = result;
    return result;
  }

  // ...........................................................................
  void _init(Tree<T>? parent) {
    _throwIfNotValidJsonKey(key);
    _throwOnForbiddenKey();
    _adoptConstructorChildren();

    // The initializer list already preset _parent, so going through the
    // parent setter would scan the new parent's children twice for a node
    // that cannot be there yet. Attach directly instead.
    if (parent != null) {
      parent._children.add(this);
      parent._makeKeysUnique();
    }
  }

  FutureOr<void> _visitFutureOr(
    List<Tree<T>> stack,
    FutureOr<void> Function(Tree<T> node) visitor,
    bool Function(Tree<T> node)? where,
    bool Function(Tree<T> node)? stopAfter,
    bool Function(Tree<T> node)? stopBefore,
  ) {
    while (stack.isNotEmpty) {
      final node = stack.removeLast();

      final matches = where == null || where(node);

      if (stopBefore != null && stopBefore(node)) {
        continue;
      }

      if (matches) {
        final result = visitor(node);
        if (result is Future) {
          return result.then((_) {
            if (stopAfter == null || !stopAfter(node)) {
              node._pushChildrenReversed(stack);
            }
            return _visitFutureOr(stack, visitor, where, stopAfter, stopBefore);
          });
        }
      }

      if (stopAfter != null && stopAfter(node)) {
        continue;
      }

      node._pushChildrenReversed(stack);
    }
    return null;
  }

  // ...........................................................................
  /// Pushes the children onto [stack] in reverse order, so that they
  /// are popped in their original order. Pushing copies the child
  /// references, which gives the same snapshot semantics as the
  /// `[...children]` copy in [visit] and [visitAsync].
  void _pushChildrenReversed(List<Tree<T>> stack) {
    final children = _children;
    for (var i = children.length - 1; i >= 0; i--) {
      stack.add(children[i]);
    }
  }

  // ...........................................................................
  /// Attaches the children pre-seeded by the constructor in one batch.
  ///
  /// Detaching each child from its old parent and assigning `_parent`
  /// directly avoids the O(children²) cost of running the [parent] setter
  /// (contains scan + key uniquification) once per child.
  void _adoptConstructorChildren() {
    if (_children.isEmpty) {
      return;
    }

    var hasDuplicates = false;

    try {
      for (final child in _children) {
        // `this` has not escaped its constructor yet, so a child can only
        // point at it when an earlier iteration of this loop adopted the
        // same instance — i.e. the child appears twice in the list.
        if (identical(child._parent, this)) {
          hasDuplicates = true;
          continue;
        }

        child._throwWhenReadonly();
        child._parent?._children.remove(child);
        child._parent = this;
      }
    } catch (_) {
      // Children attached before the throw keep pointing to this node.
      // Make their keys unique so no sibling key invariant is violated.
      _makeKeysUnique();
      rethrow;
    }

    if (hasDuplicates) {
      _removeDuplicateChildren();
    }
  }

  // ...........................................................................
  /// Keeps only the last occurrence of each duplicate child instance
  void _removeDuplicateChildren() {
    final seen = <Tree<T>>{};
    final deduped = <Tree<T>>[];
    for (final child in _children.reversed) {
      if (seen.add(child)) {
        deduped.add(child);
      }
    }
    _children
      ..clear()
      ..addAll(deduped.reversed);
  }

  // ...........................................................................
  /// Override this method in subclasses to enforce custom key rules
  void _throwOnForbiddenKey() {
    if (key.startsWith('_')) {
      throw Exception('Key "$key" must not start with _');
    }
  }

  void _throwIfNotValidJsonKey(String key) {
    if (!isValidJsonKey(key)) {
      throw Exception('$key is not a valid json identifier');
    }
  }

  // ...........................................................................
  Json _treeProps() {
    final siblingsCount = _parent?._children.length ?? 1;
    final index = _parent == null ? 0 : _siblingIndex();
    final ownPath = path;

    return <String, dynamic>{
      'key': key,
      'originalKey': originalKey,
      'isReadOnly': isReadOnly,
      'childCount': _children.length,
      'siblingsCount': siblingsCount,
      'index': index,
      'reverseIndex': siblingsCount - index - 1,
      'path': ownPath,
      'pathSimple': keepOnlyLetters(ownPath),
      'isRoot': isRoot,
    };
  }

  // ...........................................................................
  Json _toJson(Tree tree) {
    // Key insertion order matters for encoded output:
    // key, originalKey, isReadOnly, _data, _children.
    final json = <String, dynamic>{
      'key': tree.key,
      'originalKey': tree.originalKey,
      'isReadOnly': tree.isReadOnly,
      '_data': tree.data.deepCopy(),
    };

    final children = tree._children;
    if (children.isNotEmpty) {
      final childrenJson = <Json>[];
      for (var i = 0; i < children.length; i++) {
        childrenJson.add(_toJson(children[i]));
      }
      json['_children'] = childrenJson;
    }

    return json;
  }

  // ...........................................................................
  factory Tree._fromJson(Json json) {
    final ch = <Tree<T>>[];

    if (json['_children'] != null) {
      for (final childJson in (json['_children'] as List).cast<Json>()) {
        ch.add(Tree._fromJson(childJson));
      }
    }

    return Tree(
      key: json['key'] as String,
      originalKey: json['originalKey'] as String,
      parent: null,
      data: json['_data'] as T,
      children: ch,
    );
  }

  // ...........................................................................
  /// Parsed queries cached by their query string
  static final Map<String, TreeQuery> _queryCache = {};

  // ...........................................................................
  /// Parses [query] or returns a previously parsed cached instance
  static TreeQuery _parseQuery(String query) {
    final cached = _queryCache[query];
    if (cached != null) {
      return cached;
    }

    final result = TreeQuery(query);
    if (_queryCache.length >= 512) {
      _queryCache.clear();
    }
    _queryCache[query] = result;
    return result;
  }

  // ...........................................................................
  V? _getOrNull<V>(String query, {bool throwWhenNotFound = false}) {
    final q = _parseQuery(query);
    final searchToRoot = q.searchToRoot;

    // Walk from this node towards the root without materializing the
    // ancestors and apply the query to each node
    var didFindAnyNode = false;

    for (Tree<T>? node = this; node != null; node = node._parent) {
      // Get the child node described in q.node
      final dataNode = node._relative(q.nodeSegments);
      if (dataNode != null) {
        didFindAnyNode = true;

        final value = q.readsNodeInfo
            ? dataNode._treeInfo<V>(q.nodeInfoPath)
            : dataNode._data.getOrNull<V>(q.data);

        if (value != null) {
          return value;
        }
      }

      if (!searchToRoot) {
        break;
      }
    }

    if (throwWhenNotFound) {
      final nodes = searchToRoot
          ? ancestors(includeRoot: true, includeSelf: true, startAtRoot: false)
          : <Tree<T>>[this];

      if (!didFindAnyNode) {
        _throwNodeNotFound(q.node, nodes);
      } else {
        _throwPropNotFound(query, q.node, q.data, nodes);
      }
    }

    return null;
  }

  // ...........................................................................
  V _get<V>(String query) {
    final result = _getOrNull<V>(query, throwWhenNotFound: true);
    if (result == null) {}

    return result!;
  }

  // ...........................................................................
  void _set<V>(String query, V value, {bool extend = false}) {
    final q = _parseQuery(query);
    final node = findNode(q.node);
    node.data.set<V>(q.data, value, extend: extend);
  }

  // ...........................................................................
  void _remove(String query) {
    final q = _parseQuery(query);

    final node = findNode(q.node);
    if (q.data.isEmpty) {
      node.data.clear();
    }

    node.data.removeValue(q.data);
  }

  // ...........................................................................
  /// Throws an exception when this tree is readonly
  void _throwWhenReadonly() {
    if (isReadOnly) {
      throw Exception('Tree node "$key" is readonly');
    }
  }

  // ...........................................................................
  /// Private copy constructor used by [_deepCopy].
  ///
  /// Skips key validation, child adoption and key uniquification: the
  /// copied keys come from an already valid node. Mirrors the field
  /// semantics of [flatCopyWith]: `_parse` is not forwarded and the copy
  /// is never readonly. Keep the field list in sync with the main
  /// constructor when adding fields.
  Tree._copy({
    required String key,
    required this.originalKey,
    required T data,
    required this.isValidJsonKey,
  }) : _key = key,
       _data = data,
       _children = [],
       _parent = null,
       _parse = null;

  Tree<T> _deepCopy(Tree<T> tree, [bool Function(Tree<T>)? where]) {
    final result = Tree<T>._copy(
      key: tree._key,
      originalKey: tree.originalKey,
      data: tree._data.deepCopy() as T,
      isValidJsonKey: tree.isValidJsonKey,
    );

    // for-in, so that a [where] predicate mutating the source mid-copy
    // throws a ConcurrentModificationError like before
    for (final child in tree._children) {
      if (where == null || where(child)) {
        final copiedChild = _deepCopy(child, where).._parent = result;
        result._children.add(copiedChild);
      }
    }

    // Load-bearing even without a where filter: sources can contain
    // surviving suffixed keys like [a0, a2] which a copy renames to
    // [a0, a1]. Also supplies the epoch bump for the direct _parent and
    // _children writes above.
    result._makeKeysUnique();
    return result;
  }

  // ...........................................................................
  void _makeKeysUnique() {
    // Every caller of this method has mutated (or may have mutated) tree
    // structure — including the constructor, addChildren's finally block
    // and the adoption catch path — so invalidate all structure caches.
    _structureEpoch++;

    if (_children.length <= 1) {
      return;
    }

    // Detect whether any original key occurs more than once
    final seen = <String>{};
    bool hasAmbigious = false;

    for (final node in _children) {
      if (!seen.add(node.originalKey)) {
        hasAmbigious = true;
        break;
      }
    }

    if (!hasAmbigious) {
      return;
    }

    // Calculate the counts of all node names
    final nameCounts = <String, int>{};
    for (final node in _children) {
      nameCounts[node.originalKey] = (nameCounts[node.originalKey] ?? 0) + 1;
    }

    // Rename all nodes that have duplicates
    final counts = <String, int>{};

    for (final node in _children) {
      var nodKey = node.originalKey;
      if (nameCounts[nodKey]! > 1) {
        final count = counts[nodKey] ?? 0;
        counts[nodKey] = count + 1;
        nodKey = '$nodKey$count';
      }
      node._key = nodKey;
    }
  }

  // ...........................................................................
  Tree<T>? _relative(Iterable<String> path, {bool throwWhenNotFound = false}) {
    Tree<T> current = this;

    // Only the number of matched segments is tracked here. The segment list
    // needed for the error message is derived from it on the throw path.
    var okCount = 0;

    for (final segment in path) {
      if (segment.isEmpty || segment == '.') {
        okCount++;
        continue;
      }

      if (segment == '..') {
        final parent = current.parent;
        if (parent == null) {
          return null;
        }

        current = parent;
        okCount++;
        continue;
      }

      final child = current.childByKey(segment);
      if (child == null) {
        if (throwWhenNotFound) {
          _throwRelativePathNotFound(
            path,
            current,
            path.take(okCount).toList(),
          );
        }
        return null;
      }

      current = child;
      okCount++;
    }
    return current;
  }

  // ...........................................................................
  Tree<T>? _absolute(Iterable<String> path) => root.relative(path);

  Tree<T>? _childByPath(String path, {bool throwWhenNotFound = false}) {
    _validateResolutionCaches();
    final cache = _childByPathCache ??= <String, Tree<T>>{};
    final cached = cache[path];
    if (cached != null) {
      return cached;
    }

    final result = _relative(
      _splitPath(path),
      throwWhenNotFound: throwWhenNotFound,
    );

    // Only found nodes are cached: the not-found error messages must be
    // rebuilt from the live tree on every throwing lookup.
    if (result != null) {
      if (cache.length >= _maxResolutionCacheLength) {
        cache.clear();
      }
      cache[path] = result;
    }
    return result;
  }

  // ...........................................................................
  Tree<T>? _findNode(String path, {bool throwWhenNotFound = false}) {
    if (path.isEmpty) {
      path = '.';
    }

    _validateResolutionCaches();
    final cache = _findNodeCache ??= <String, Tree<T>>{};
    final cached = cache[path];
    if (cached != null) {
      return cached;
    }

    final segments = _splitPath(path);
    final fromRoot = path.startsWith('/');

    final result = fromRoot
        ? _findNodeAbsolute(segments, throwWhenNotFound)
        : _findNodeRelative(segments, throwWhenNotFound);

    // Only found nodes are cached: the not-found error messages must be
    // rebuilt from the live tree on every throwing lookup.
    if (result != null) {
      if (cache.length >= _maxResolutionCacheLength) {
        cache.clear();
      }
      cache[path] = result;
    }
    return result;
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
    final result = <Tree<T>>[];
    Tree<T>? current = includeSelf ? this : parent;
    while (current != null) {
      result.add(current);
      current = current.parent;
    }

    if (!includeRoot) {
      result.removeLast();
    }
    return startAtRoot ? result.reversed : result;
  }

  // ...........................................................................
  Tree<T>? _findNodeAbsolute(List<String> segments, bool throwWhenNotFound) {
    // Return root when path is empty
    if (segments.isEmpty) {
      return root;
    }

    // Get all ancestors from root to this node
    final nodes = ancestors(
      includeSelf: true,
      includeRoot: false,
      startAtRoot: true,
    ).toList();

    // The current position within the path segments
    var s = 0;

    final okSegments = <String>[];

    // Iterate through all ancestors
    for (var i = 0; i < nodes.length; i++) {
      // Get current and next node
      final node = nodes[i];
      final nextNode = i + 1 < nodes.length ? nodes[i + 1] : null;
      final segment = segments[s];
      final nextSegment = s + 1 < segments.length ? segments[s + 1] : null;

      // Check for match
      if (node.key == segment || segment == '*' || segment == '**') {
        okSegments.add(segment);

        // Jump to next search segment. A '**' segment is kept as long as
        // the next ancestor does not match the next segment.
        final keepSegment =
            segment == '**' && nextNode != null && nextNode.key != nextSegment;
        if (!keepSegment) {
          s++;
        }

        // If this is the last segment, return the node
        if (s >= segments.length) {
          return node;
        }

        // Continue to next ancestor
        continue;
      }
      // If no match
      else {
        // throw when not found
        if (throwWhenNotFound) {
          _throwAbsolutePathNotFound(segments, node, okSegments);
        }

        // or return null
        return null;
      }
    }

    final result = nodes.last.relative(['.', ...segments.skip(s)]);

    if (result == null && throwWhenNotFound) {
      _throwAbsolutePathNotFound(segments, nodes.last, okSegments);
    }
    return result;
  }

  // ...........................................................................
  void _throwAbsolutePathNotFound(
    Iterable<String> path,
    Tree<T> node,
    List<String> okSegments,
  ) {
    final prefix = okSegments.join('/');
    final possiblePaths = node
        .ls(showProps: false)
        .map((e) => '  - /$prefix${e.substring(1)}');

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
  String _createRelativePath(String path, String prefix) {
    final result = '$prefix${path.substring(1)}';
    return result.isEmpty
        ? '.'
        : result.startsWith('/')
        ? '.$result'
        : result;
  }

  // ...........................................................................
  void _throwRelativePathNotFound(
    Iterable<String> path,
    Tree<T> node,
    List<String> okSegments,
  ) {
    final prefix = okSegments.join('/');
    final possiblePaths = node
        .ls(showProps: false)
        .map((e) => '  - ${_createRelativePath(e, prefix)}');
    throw Exception(
      [
        'Could not find node "${path.join('/')}"',
        '',
        'Possible paths:',
        ...possiblePaths,
      ].join('\n'),
    );
  }

  // ...........................................................................
  void _throwNodeNotFound(String nodeName, Iterable<Tree> ancestors) {
    final allNodes = <String>[];

    for (final a in ancestors) {
      allNodes.addAll(
        a
            .ls()
            .where((element) => element != '.')
            .map((e) => e.replaceFirst('./', '')),
      );
    }

    throw Exception(
      [
        'Cannot find node "$nodeName":',
        '',
        'Available nodes:',
        ...allNodes.map((e) => '  - $e'),
      ].join('\n'),
    );
  }

  // ...........................................................................
  void _throwPropNotFound(
    String query,
    String nodePath,
    String prop,
    Iterable<Tree> nodes,
  ) {
    final allProps = <String>{};
    for (final n in nodes) {
      allProps.addAll(
        n
            .lsProps()
            .map((e) => e.split('#').last)
            .where((e) => e.isNotEmpty && e != '.')
            .map((e) => '  - $nodePath#$e'),
      );
    }

    throw Exception(
      [
        'Cannot resolve query "$query".',
        '',
        'Available paths:',
        ...allProps,
      ].join('\n'),
    );
  }

  // ...........................................................................
  void _pathToTreeMap(
    String path,
    Map<String, Tree<T>> result, {
    bool Function(Tree<T> slot)? where,
  }) {
    final skip = where == null ? false : !where(this);
    if (!skip) {
      result[path.isEmpty ? '/' : path] = this;
    }

    // for-in, so that a [where] predicate mutating the tree mid-walk
    // throws a ConcurrentModificationError like before
    for (final child in _children) {
      child._pathToTreeMap('$path/${child._key}', result, where: where);
    }
  }

  // ...........................................................................
  V? _treeInfo<V>(String dataKey) => _treeProps().getOrNull<V>(dataKey);

  // ...........................................................................
  P _parsed<P>() {
    Tree? current = this;
    P Function(Json)? parse = _parse;

    while (current != null && parse == null) {
      current = current.parent;
      parse = current?._parse;
    }

    if (parse == null) {
      throw Exception('No parse function provided.');
    }

    try {
      return parse(_data);
    } catch (e) {
      throw Exception(
        ['Failed to parse data of node "$key" to type $P:', '$e'].join('\n'),
      );
    }
  }

  Tree<T>? get _nextSibling {
    final siblings = _parent?._children;
    if (siblings == null) {
      return null;
    }

    final i = _siblingIndex();
    return i + 1 < siblings.length ? siblings[i + 1] : null;
  }

  Tree<T>? get _previousSibling {
    final siblings = _parent?._children;
    if (siblings == null) {
      return null;
    }

    final i = _siblingIndex();
    return i > 0 ? siblings[i - 1] : null;
  }
}
