// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

part of 'tree.dart';

/// The output format used by [TreeLs.ls]
enum TreeLsFormat {
  /// One line per node, listing the full path of each node
  paths,

  /// An ASCII art tree
  txtTree,

  /// A Markdown list with indented lines starting with `- `
  markdown,
}

/// Builds the label for a data node. Complex values are rendered as just the
/// [key] (their content becomes children), string values are wrapped in `""`,
/// and other scalars are shown as is. Data root nodes are prefixed with `#`.
String _dataLabel(String key, dynamic value, {required bool isRoot}) {
  final prefix = isRoot ? '#' : '';
  if (value is Map || value is List) {
    return '$prefix$key';
  }
  final renderedValue = value is String ? '"$value"' : '$value';
  return '$prefix$key = $renderedValue';
}

/// Private implementation of the `ls` family of methods declared on [Tree].
///
/// The public entry points live on [Tree] itself (as instance methods) so that
/// they are inherited by derived classes and visible on `Tree<dynamic>`, which
/// an extension's `on Tree<T extends Json>` clause would not cover.
extension _TreeLs<T extends Json> on Tree<T> {
  // ...........................................................................
  /// Lists all objects paths of this tree, see [Tree.ls].
  List<String> lsPaths({
    String prefix = '',
    bool Function(Tree<T> node)? where,
    bool showProps = false,
    bool withValues = false,
    bool alsoComplexValues = false,
    WhereProp? whereProp,
    TreeLsFormat format = TreeLsFormat.paths,
  }) {
    switch (format) {
      case TreeLsFormat.paths:
        final paths = <String>[];

        _ls(
          paths,
          '.',
          where: where,
          showProps: showProps,
          withValues: withValues,
          alsoComplexValues: alsoComplexValues,
          whereProp: whereProp,
        );
        return prefix.isEmpty ? paths : paths.map((e) => '$prefix$e').toList();

      case TreeLsFormat.txtTree:
        return _lsTxtTree(withValues: withValues);

      case TreeLsFormat.markdown:
        return _lsMarkdown(withValues: withValues);
    }
  }

  // ...........................................................................
  /// Renders this tree as an ASCII tree, see [TreeLsFormat.txtTree].
  ///
  /// The tree is walked with [Tree.visit] and, when [withValues] is true, the
  /// json [Tree.data] of each node is walked with [Json.visit] so the data
  /// content is rendered as a tree rather than a plain text string.
  List<String> _lsTxtTree({required bool withValues}) {
    final lines = <String>[];

    visit((node) {
      if (identical(node, this)) {
        lines.add(node.key);
      } else {
        final connector = _isLastChild(node) ? '└── ' : '├── ';
        lines.add('${_ancestorPrefix(node)}$connector${node.key}');
      }

      if (withValues) {
        _appendDataTxtTree(node, lines);
      }
    });

    return lines;
  }

  // ...........................................................................
  /// Appends the json [Tree.data] of [node] as an ASCII sub-tree to [lines].
  void _appendDataTxtTree(Tree<T> node, List<String> lines) {
    final base = _childPrefix(node);
    // `branchLast[d - 1]` tells whether the ancestor at depth `d` is the last
    // of its siblings. It is maintained as [Json.visit] walks in pre-order.
    final branchLast = <bool>[];

    node.data.visit(({key, value, parent, ancestors}) {
      final depth = ancestors!.length;
      final isLast = _isLastDataEntry(
        key: key,
        parent: parent,
        // top-level data entries are followed by the tree children of [node]
        isTopLevel: depth == 1,
        hasTreeChildren: node.children.isNotEmpty,
      );

      if (branchLast.length < depth) {
        branchLast.add(isLast);
      } else {
        branchLast[depth - 1] = isLast;
      }

      final buffer = StringBuffer(base);
      for (var i = 0; i < depth - 1; i++) {
        buffer.write(branchLast[i] ? '    ' : '│   ');
      }
      buffer
        ..write(isLast ? '└── ' : '├── ')
        ..write(_dataLabel('$key', value, isRoot: depth == 1));
      lines.add(buffer.toString());
    });
  }

  // ...........................................................................
  /// Renders this tree as an indented markdown list, see
  /// [TreeLsFormat.markdown].
  List<String> _lsMarkdown({required bool withValues}) {
    final lines = <String>[];

    visit((node) {
      final depth = _depth(node);
      lines.add('${'  ' * depth}- ${node.key}');

      if (withValues) {
        node.data.visit(({key, value, parent, ancestors}) {
          final isRoot = ancestors!.length == 1;
          lines.add(
            '${'  ' * (depth + ancestors.length)}- '
            '${_dataLabel('$key', value, isRoot: isRoot)}',
          );
        });
      }
    });

    return lines;
  }

  // ...........................................................................
  /// Whether [node] is the last child of its parent.
  bool _isLastChild(Tree<T> node) {
    final parent = node.parent;
    return parent == null || identical(parent.children.last, node);
  }

  // ...........................................................................
  /// The number of tree levels between [node] and this node (the ls root).
  int _depth(Tree<T> node) {
    var depth = 0;
    for (var a = node; !identical(a, this); a = a.parent!) {
      depth++;
    }
    return depth;
  }

  // ...........................................................................
  /// The ASCII prefix drawn before the connector of [node].
  String _ancestorPrefix(Tree<T> node) {
    final segments = <String>[];
    for (var a = node.parent; a != null && !identical(a, this); a = a.parent) {
      segments.add(_isLastChild(a) ? '    ' : '│   ');
    }
    return segments.reversed.join();
  }

  // ...........................................................................
  /// The ASCII prefix drawn before the children (data and nodes) of [node].
  String _childPrefix(Tree<T> node) => identical(node, this)
      ? ''
      : '${_ancestorPrefix(node)}${_isLastChild(node) ? '    ' : '│   '}';

  // ...........................................................................
  /// Whether a data entry is the last of its siblings. Top-level entries are
  /// only last when [node] has no tree children drawn after them.
  bool _isLastDataEntry({
    required dynamic key,
    required dynamic parent,
    required bool isTopLevel,
    required bool hasTreeChildren,
  }) {
    final lastInParent = parent is List
        ? key == parent.length - 1
        : (parent as Map).keys.last == key;
    return isTopLevel ? lastInParent && !hasTreeChildren : lastInParent;
  }

  // ...........................................................................
  void _ls(
    List<String> paths,
    String ownPath, {
    bool Function(Tree<T> node)? where,
    required bool showProps,
    required bool withValues,
    required bool alsoComplexValues,
    required WhereProp? whereProp,
  }) {
    if (where == null || where(this)) {
      if (!showProps) {
        paths.add(ownPath);
      }

      // Write data properties
      _addProps(
        showProps,
        paths,
        ownPath,
        addTreeProps: false,
        withValues: withValues,
        alsoComplexValues: alsoComplexValues,
        whereProp: whereProp,
      );

      // Write tree properties
      _addProps(
        showProps,
        paths,
        ownPath,
        addTreeProps: true,
        withValues: withValues,
        alsoComplexValues: alsoComplexValues,
        whereProp: whereProp,
      );
    }

    for (final child in children) {
      child._ls(
        paths,
        '$ownPath/${child.key}',
        where: where,
        showProps: showProps,
        alsoComplexValues: alsoComplexValues,
        withValues: withValues,
        whereProp: whereProp,
      );
    }
  }

  // ...........................................................................
  void _addProps(
    bool showDataPaths,
    List<String> paths,
    String ownPath, {
    required bool addTreeProps,
    required bool withValues,
    required bool alsoComplexValues,
    required WhereProp? whereProp,
  }) {
    if (showDataPaths) {
      final data = addTreeProps ? _treeProps(this, true) : _data;
      final dataPaths = data.ls(
        writeValues: withValues,
        alsoComplexValues: alsoComplexValues,
        where: whereProp,
      );

      for (var dataPath in dataPaths) {
        final node = addTreeProps ? 'node/' : '';
        paths.add('$ownPath#$node${dataPath.replaceFirst('./', '')}');
      }
    }
  }
}
