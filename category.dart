// lib/model/category.dart
import 'package:flutter/material.dart';

class Category {
  String? id; 
  String name;
  String type;
  int? color;
  String? userId;

  Category({this.id, required this.name, required this.type, this.color, this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color': color,
      'userId': userId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String?, 
      name: map['name'] as String,
      type: map['type'] as String,
      color: map['color'] as int?,
      userId: map['userId'] as String?,
    );
  }

  Color get flutterColor => color != null ? Color(color!) : Colors.grey;

  set flutterColor(Color value) {
    color = value.value;
  }
}
