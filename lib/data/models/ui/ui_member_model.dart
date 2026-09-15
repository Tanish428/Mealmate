import 'package:flutter/material.dart';

class UIMemberModel {
  final String id;
  final String name;
  final String avatarInitials;
  final Color avatarColor;
  final String dietaryPreference; // 'Veg' or 'Non-Veg'
  final String paymentStatus; // 'Fees Paid' or 'Payment Due'

  const UIMemberModel({
    required this.id,
    required this.name,
    required this.avatarInitials,
    required this.avatarColor,
    required this.dietaryPreference,
    required this.paymentStatus,
  });

  UIMemberModel copyWith({
    String? id,
    String? name,
    String? avatarInitials,
    Color? avatarColor,
    String? dietaryPreference,
    String? paymentStatus,
  }) {
    return UIMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      avatarColor: avatarColor ?? this.avatarColor,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
