import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class OrbitFormManager {
  final Map<String, BehaviorSubject<dynamic>> _subjects = {};

  BehaviorSubject get(String key) {
    if (!_subjects.containsKey(key)) {
      _subjects[key] = BehaviorSubject();
      _subjects[key]!.add(null);
    }

    return _subjects[key]!;
  }

  void set(String key, dynamic value) {
    final subject = get(key);
    subject.add(value);
  }
}

class DropdownOption {
  final String? id;
  final String title;
  final String? subtitle;
  final String? profileImageUrl;
  final IconData? actionIcon;
  final dynamic data;

  DropdownOption({this.id, required this.title, this.subtitle, this.profileImageUrl, this.actionIcon, this.data});

  @override
  bool operator ==(Object other) => identical(this, other) || other is DropdownOption && runtimeType == other.runtimeType && id == other.id && title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
