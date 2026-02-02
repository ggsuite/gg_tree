// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_json/gg_json.dart';
import 'package:gg_tree/gg_tree.dart';
import 'package:test/test.dart';

void main() {
  group('TreeData', () {
    late ExampleData exampleData;

    setUp(() {
      exampleData = ExampleData.example();
    });

    group('example', () {
      test('should work', () {
        expect(exampleData, isNotNull);
      });
    });

    test('data', () {
      expect(exampleData.data, exampleJson);
    });

    test('toJson, fromJson', () {
      final json = exampleData.toJson();
      expect(json, exampleJson);

      final fromJson = exampleData.fromJson(json);
      expect(fromJson.data, exampleData.data);

      final fromJsonFactory = ExampleData.fromJson(json);
      expect(fromJsonFactory.data, exampleData.data);
    });
  });
}
