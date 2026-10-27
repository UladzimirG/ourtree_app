import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/paper_card.dart';

/// Показывает содержимое как «бумажку» на затемнённом фоне снизу экрана.
Future<void> showCardSheet(
  BuildContext context,
  WidgetBuilder builder, {
  double maxWidth = 420,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16 + bottomInset),
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: PaperCard(
                  tilt: 0.6,
                  child: builder(sheetContext),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
