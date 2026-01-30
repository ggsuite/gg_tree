// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';

// .............................................................................
/// Interface for all tree data
abstract class TreeData {
  /// Converts the tree data to JSON
  Json toJson();

  /// Creates tree data from JSON
  TreeData fromJson(Json json);
}

// .............................................................................
/// Example implementation of [TreeData]
class ExampleData implements TreeData {
  /// Constructor
  ExampleData(this.data);

  /// Example instance for test purposes
  factory ExampleData.example() => ExampleData(exampleJson);

  /// The example data
  final Json data;

  @override
  Json toJson() {
    return deepCopy(data);
  }

  @override
  ExampleData fromJson(Json json) {
    return ExampleData(json);
  }

  /// Convenience method to create from JSON
  factory ExampleData.fromJson(Json json) =>
      ExampleData.example().fromJson(json);
}
