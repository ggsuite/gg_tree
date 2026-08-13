// @license
// Copyright (c) ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// Performance benchmark for gg_tree.
///
/// Run with `dart run benchmark/gg_tree_benchmark.dart` from the package
/// root. Pass `--quick` to divide all iteration counts by 10 (smoke test).
///
/// All trees are built deterministically (fixed shapes, fixed data, no
/// randomness). Each case is run a few times as warmup and then timed over
/// a fixed number of iterations. Each case prints exactly one line:
///
///     name: X.XXX ms (N iterations)
///
/// where X.XXX is the average wall time of one iteration in milliseconds.
library;

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';

// .............................................................................
// Tree builders

/// Returns the deterministic node payload for index [i].
Json nodeData(int i) => {'v': i, 'name': 'node_$i'};

/// Builds a tree with [n] children directly under one root.
Tree<Json> wideTree(int n) {
  final children = List.generate(
    n,
    (i) => Tree<Json>(key: 'c$i', data: nodeData(i)),
  );
  return Tree<Json>(key: 'root', data: nodeData(0), children: children);
}

/// Builds a linear chain of [depth] nodes below the root.
Tree<Json> deepTree(int depth) {
  final root = Tree<Json>(key: 'root', data: nodeData(0));
  var current = root;
  for (var i = 1; i <= depth; i++) {
    current = Tree<Json>(key: 'n$i', parent: current, data: nodeData(i));
  }
  return root;
}

/// Builds a bushy tree where every node down to [depth] levels below the
/// root has [fanout] children (keys `n0` .. `n{fanout-1}` per level).
Tree<Json> bushyTree(int fanout, int depth) =>
    _bushy('root', fanout, depth, [0]);

Tree<Json> _bushy(String key, int fanout, int levels, List<int> counter) {
  final children = <Tree<Json>>[];
  if (levels > 0) {
    for (var i = 0; i < fanout; i++) {
      children.add(_bushy('n$i', fanout, levels - 1, counter));
    }
  }
  return Tree<Json>(key: key, data: nodeData(counter[0]++), children: children);
}

/// Returns the leftmost leaf of [tree].
Tree<Json> firstLeaf(Tree<Json> tree) {
  var current = tree;
  while (current.children.isNotEmpty) {
    current = current.children.first;
  }
  return current;
}

// .............................................................................
// Benchmark harness

/// Sink to prevent the optimizer from eliminating benchmark work.
int sink = 0;

/// Runs [body] [warmup] times untimed, then [iterations] times timed, and
/// prints the average duration of one iteration in milliseconds.
void bench(
  String name,
  int iterations,
  void Function() body, {
  int warmup = 2,
  required bool quick,
}) {
  var iters = quick ? iterations ~/ 10 : iterations;
  if (iters < 1) {
    iters = 1;
  }

  for (var i = 0; i < warmup; i++) {
    body();
  }

  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iters; i++) {
    body();
  }
  stopwatch.stop();

  final ms = stopwatch.elapsedMicroseconds / 1000 / iters;
  print('$name: ${ms.toStringAsFixed(3)} ms ($iters iterations)');
}

// .............................................................................
/// Entry point.
void main(List<String> args) {
  final quick = args.contains('--quick');

  // ...........................................................................
  // a. construct_wide_10k: build a tree with 10000 children under one root
  // via Tree(children: ...).
  bench('construct_wide_10k', 2, warmup: 1, quick: quick, () {
    sink += wideTree(10000).children.length;
  });

  // ...........................................................................
  // b. add_children_5k: root, then addChildren with 5000 nodes.
  bench('add_children_5k', 3, warmup: 1, quick: quick, () {
    final root = Tree<Json>(key: 'root', data: nodeData(0));
    final children = List.generate(
      5000,
      (i) => Tree<Json>(key: 'c$i', data: nodeData(i)),
    );
    root.addChildren(children);
    sink += root.children.length;
  });

  // ...........................................................................
  // c. deep_copy_bushy: deepCopy of bushyTree(8, 5) (~37449 nodes).
  final bushy85 = bushyTree(8, 5);
  bench('deep_copy_bushy', 10, quick: quick, () {
    sink += bushy85.deepCopy().children.length;
  });

  // ...........................................................................
  // d. child_by_path: 10000 childByPath lookups of a leaf in bushyTree(5, 5).
  final bushy55 = bushyTree(5, 5);
  bench('child_by_path', 20, quick: quick, () {
    for (var i = 0; i < 10000; i++) {
      sink += bushy55.childByPath('n0/n1/n2/n3/n4').key.length;
    }
  });

  // ...........................................................................
  // e. find_node_absolute: 10000 absolute findNode lookups of the leaf of a
  // depth-30 chain, executed from the leaf itself.
  final deep30 = deepTree(30);
  final leaf30 = firstLeaf(deep30);
  final absPath = leaf30.path; // '/n1/n2/.../n30'
  bench('find_node_absolute', 10, quick: quick, () {
    for (var i = 0; i < 10000; i++) {
      sink += leaf30.findNode(absPath).key.length;
    }
  });

  // ...........................................................................
  // f. find_node_relative_up: 10000 findNode('x/y') from the deep leaf; the
  // path only resolves at the root, so every lookup walks all 30 ancestors.
  final x = Tree<Json>(key: 'x', parent: deep30, data: nodeData(1000));
  final y = Tree<Json>(key: 'y', parent: x, data: nodeData(1001));
  sink += y.key.length;
  bench('find_node_relative_up', 15, quick: quick, () {
    for (var i = 0; i < 10000; i++) {
      sink += leaf30.findNode('x/y').key.length;
    }
  });

  // ...........................................................................
  // g. get_query: 10000 getOrNull('.#v') plus 10000 getOrNull('#v') from the
  // deep leaf of the depth-30 chain.
  bench('get_query', 10, quick: quick, () {
    for (var i = 0; i < 10000; i++) {
      sink += leaf30.getOrNull<int>('.#v') ?? 0;
    }
    for (var i = 0; i < 10000; i++) {
      sink += leaf30.getOrNull<int>('#v') ?? 0;
    }
  });

  // ...........................................................................
  // h. to_json: toJson() of bushyTree(6, 5) (9331 nodes).
  final bushy65 = bushyTree(6, 5);
  bench('to_json', 20, quick: quick, () {
    sink += bushy65.toJson().length;
  });

  // ...........................................................................
  // i. ls_paths: ls() of bushyTree(6, 5).
  bench('ls_paths', 200, warmup: 5, quick: quick, () {
    sink += bushy65.ls().length;
  });

  // ...........................................................................
  // j. ls_props_values: lsProps(withValues: true) of bushyTree(4, 4)
  // (341 nodes).
  final bushy44 = bushyTree(4, 4);
  bench('ls_props_values', 30, warmup: 3, quick: quick, () {
    sink += bushy44.lsProps(withValues: true).length;
  });

  // ...........................................................................
  // k. visit_all: visit counting all nodes of bushyTree(6, 5), 20 iterations.
  bench('visit_all', 20, warmup: 5, quick: quick, () {
    var count = 0;
    bushy65.visit((node) => count++);
    sink += count;
  });

  // ...........................................................................
  // l. path_of_deep_leaf: .path of a depth-100 leaf; one benchmark
  // iteration performs 10000 path reads.
  final leaf100 = firstLeaf(deepTree(100));
  bench('path_of_deep_leaf', 8, quick: quick, () {
    for (var i = 0; i < 10000; i++) {
      sink += leaf100.path.length;
    }
  });

  // ...........................................................................
  // m. path_to_tree_map: pathToTreeMap() of bushyTree(6, 5).
  bench('path_to_tree_map', 100, warmup: 5, quick: quick, () {
    sink += bushy65.pathToTreeMap().length;
  });

  // ...........................................................................
  // n. next_prev_sibling: nextSibling + previousSibling across all 5000
  // children of a wide node.
  final wide5k = wideTree(5000);
  bench('next_prev_sibling', 3, warmup: 1, quick: quick, () {
    var count = 0;
    for (final child in wide5k.children) {
      if (child.nextSibling != null) {
        count++;
      }
      if (child.previousSibling != null) {
        count++;
      }
    }
    sink += count;
  });

  // Keep the sink alive so no benchmark body can be optimized away.
  if (sink == -1) {
    print('unreachable');
  }
}
