import 'package:flutter/material.dart';

class Feature {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
} 