import 'package:flutter/foundation.dart';
import 'package:schedule_app/features/schedule/domain/entities/subgroup.dart';

@immutable
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.subgroups,
  });

  final String id;
  final String name;
  final List<Subgroup> subgroups;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subgroups': subgroups.map((item) => item.toJson()).toList(growable: false),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    final rawSubgroups = json['subgroups'];
    final subgroups = rawSubgroups is List
        ? rawSubgroups
            .whereType<Map>()
            .map((item) => Subgroup.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false)
        : const <Subgroup>[];

    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subgroups: subgroups,
    );
  }
}

