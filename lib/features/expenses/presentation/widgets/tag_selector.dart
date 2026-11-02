import 'package:flutter/material.dart';

import 'package:expense_tracker_by_na/core/constants/transaction_tags.dart';

/// Multi-select chips for predefined transaction tags.
class TagSelector extends StatelessWidget {
  const TagSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in TransactionTags.all)
          FilterChip(
            label: Text(tag),
            selected: selected.contains(tag),
            onSelected: (isSelected) {
              final next = List<String>.from(selected);
              if (isSelected) {
                if (!next.contains(tag)) next.add(tag);
              } else {
                next.remove(tag);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
