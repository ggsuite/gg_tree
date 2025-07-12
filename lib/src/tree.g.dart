// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tree _$TreeFromJson(Map<String, dynamic> json) => Tree(
  item: json['item'] as Map<String, dynamic>,
  children:
      (json['children'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Tree.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$TreeToJson(Tree instance) => <String, dynamic>{
  'item': instance.item,
  'children': instance.children.map((k, e) => MapEntry(k, e.toJson())),
};
