import 'package:flutter/material.dart';

enum AppSection {
  feed('Nhật ký ảnh', Icons.camera_roll_rounded),
  dashboard('Tổng quan', Icons.space_dashboard_rounded),
  statistics('Thống kê', Icons.insights_rounded),
  budget('Ngân sách', Icons.savings_rounded);

  final String label;
  final IconData icon;

  const AppSection(this.label, this.icon);
}
