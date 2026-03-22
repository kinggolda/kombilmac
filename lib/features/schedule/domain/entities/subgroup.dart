import 'package:flutter/foundation.dart';

@immutable
class Subgroup {
  const Subgroup({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Subgroup.fromJson(Map<String, dynamic> json) {
    return Subgroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

