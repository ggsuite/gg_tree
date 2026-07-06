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

        // The prefix is baked into the root path so that no second pass
        // over the result is needed.
        _ls(
          paths,
          '$prefix.',
          where: where,
          showProps: showProps,
          withValues: withValues,
          alsoComplexValues: alsoComplexValues,
          whereProp: whereProp,
        );
        return paths;

      case TreeLsFormat.txtTree:
        return _lsTxtTree(withValues: withValues);

      case TreeLsFormat.markdown:
        return _lsMarkdown(withValues: withValues);
    }
  }

  // ...........................................................................
  /// Renders this tree as an ASCII tree, see [TreeLsFormat.txtTree].
  ///
  /// The accumulated ASCII prefix is carried down the recursion, so every
  /// prefix is built with one O(1) concatenation per level instead of a
  /// repeated ancestor walk per node.
  List<String> _lsTxtTree({required bool withValues}) {
    final lines = <String>[];
    _renderTxtTree(lines, key, '', withValues: withValues);
    return lines;
  }

  // ...........................................................................
  /// Adds the line of this node, its data and its children to [lines].
  ///
  /// [line] is the fully rendered line of this node. [childPrefix] is the
  /// ASCII prefix drawn before the children (data and nodes) of this node.
  void _renderTxtTree(
    List<String> lines,
    String line,
    String childPrefix, {
    required bool withValues,
  }) {
    lines.add(line);

    if (withValues) {
      _appendDataTxtTree(lines, childPrefix);
    }

    final children = _children;
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;
      child._renderTxtTree(
        lines,
        '$childPrefix${isLast ? '└── ' : '├── '}${child.key}',
        '$childPrefix${isLast ? '    ' : '│   '}',
        withValues: withValues,
      );
    }
  }

  // ...........................................................................
  /// Appends the json [Tree.data] of this node as an ASCII sub-tree to
  /// [lines]. [base] is the ASCII prefix drawn before each data line.
  void _appendDataTxtTree(List<String> lines, String base) {
    // `branchLast[d - 1]` tells whether the ancestor at depth `d` is the last
    // of its siblings. It is maintained as [Json.visit] walks in pre-order.
    final branchLast = <bool>[];

    data.visit((key, value, parent, ancestors) {
      final depth = ancestors.length;
      final isLast = _isLastDataEntry(
        key: key,
        parent: parent,
        // top-level data entries are followed by the tree children
        isTopLevel: depth == 1,
        hasTreeChildren: children.isNotEmpty,
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
    _renderMarkdown(lines, 0, withValues: withValues);
    return lines;
  }

  // ...........................................................................
  /// Adds the markdown line of this node, its data and its children to
  /// [lines]. [depth] is tracked during the recursion so that no ancestor
  /// walk per node is needed.
  void _renderMarkdown(
    List<String> lines,
    int depth, {
    required bool withValues,
  }) {
    lines.add('${'  ' * depth}- $key');

    if (withValues) {
      data.visit((key, value, parent, ancestors) {
        final isRoot = ancestors.length == 1;
        lines.add(
          '${'  ' * (depth + ancestors.length)}- '
          '${_dataLabel('$key', value, isRoot: isRoot)}',
        );
      });
    }

    for (final child in _children) {
      child._renderMarkdown(lines, depth + 1, withValues: withValues);
    }
  }

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
      } else {
        // Write data properties
        _addProps(
          paths,
          ownPath,
          addTreeProps: false,
          withValues: withValues,
          alsoComplexValues: alsoComplexValues,
          whereProp: whereProp,
        );

        // Write tree properties
        _addProps(
          paths,
          ownPath,
          addTreeProps: true,
          withValues: withValues,
          alsoComplexValues: alsoComplexValues,
          whereProp: whereProp,
        );
      }
    }

    // for-in, so that a [where] predicate mutating the tree mid-walk
    // throws a ConcurrentModificationError like before
    for (final child in _children) {
      child._ls(
        paths,
        '$ownPath/${child._key}',
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
    List<String> paths,
    String ownPath, {
    required bool addTreeProps,
    required bool withValues,
    required bool alsoComplexValues,
    required WhereProp? whereProp,
  }) {
    final data = addTreeProps ? _treeProps() : _data;
    final dataPaths = data.ls(
      writeValues: withValues,
      alsoComplexValues: alsoComplexValues,
      where: whereProp,
    );

    final node = addTreeProps ? 'node/' : '';
    for (var dataPath in dataPaths) {
      final cleaned = dataPath.startsWith('./')
          ? dataPath.substring(2)
          : dataPath;
      paths.add('$ownPath#$node$cleaned');
    }
  }
}
