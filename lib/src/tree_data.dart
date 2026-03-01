// @license
// Copyright (c) 2026 ggsuite
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';

// .............................................................................
/// Example implementation of [TreeData]
extension type ExampleData(Json data) implements Json {
  /// Get key
  set key(String value) => data['key'] = value;

  /// Set key
  String get key => data['key'] as String? ?? '';

  /// Returns an example object
  factory ExampleData.example() => ExampleData(exampleJson.deepCopy());
}
