import 'package:flutter/material.dart';
import 'package:ourtree_app/core/theme/app_theme.dart';
import 'package:ourtree_app/features/family/presentation/widgets/family_photo.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';

/// Круглый аватар члена семьи: фото из ассетов или инициал на акцентном фоне.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.member,
    this.size = 64,
  });

  final FamilyMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor(member.accent);
    final trimmedName = member.name.trim();
    final initial = trimmedName.isEmpty ? '?' : trimmedName.substring(0, 1);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            accent,
            Color.lerp(accent, Colors.black, 0.18) ?? accent,
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: FamilyPhoto(
          source: member.photo,
          fit: BoxFit.cover,
          alignment: photoAlignment(member.photoPosition),
          zoom: member.photoZoom ?? 1.4,
          fallback: Center(
            child: Text(
              initial.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Georgia',
                fontFamilyFallback: const <String>['Times New Roman', 'serif'],
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
                color: AppColors.sticker,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _accentColor(String value) {
  final hex = value.replaceFirst('#', '').trim();
  if (hex.length != 6) return AppColors.kraft;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? AppColors.kraft : Color(0xFF000000 | parsed);
}
