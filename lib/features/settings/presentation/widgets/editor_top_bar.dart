import 'package:flutter/material.dart';

/// Верхняя панель полноэкранного редактора участника или события.
class EditorTopBar extends StatelessWidget {
  const EditorTopBar({
    super.key,
    required this.title,
    required this.doneLabel,
    required this.onDone,
  });

  final String title;
  final String doneLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          TextButton(
            onPressed: onDone,
            child: Text(doneLabel),
          ),
        ],
      ),
    );
  }
}
