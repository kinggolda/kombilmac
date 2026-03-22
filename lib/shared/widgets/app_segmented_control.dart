import 'package:flutter/material.dart';

class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.multiSelectionEnabled = false,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool multiSelectionEnabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      showSelectedIcon: false,
      multiSelectionEnabled: multiSelectionEnabled,
      segments: segments,
      selected: selected,
      onSelectionChanged: onSelectionChanged,
    );
  }
}

