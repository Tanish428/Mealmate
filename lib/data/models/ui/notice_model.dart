import 'package:flutter/material.dart';

class NoticeModel {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  final IconData iconType;
  final bool isRead;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.iconType,
    required this.isRead,
  });
}
