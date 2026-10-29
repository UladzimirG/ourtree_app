import 'dart:async';

import 'package:ourtree_app/features/family/data/repositories/family_repository.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/media/domain/models/media_asset.dart';
import 'package:ourtree_app/features/profile/domain/models/profile_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';
import 'package:ourtree_app/features/settings/presentation/providers/locale_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'family_provider.g.dart';

/// Разделы нижней навигации.
enum HomeTab {
  timeline,
  calendar,
  family,
}

/// Текущий выбранный раздел главного экрана.
@Riverpod(keepAlive: true)
class HomeTabController extends _$HomeTabController {
  @override
  HomeTab build() => HomeTab.timeline;

  void select(HomeTab tab) => state = tab;
}

/// Репозиторий, из которого читаются данные семьи.
@Riverpod(keepAlive: true)
FamilyRepository familyRepository(Ref ref) => const FamilyRepository();

/// Изменяемое состояние семейного древа.
@Riverpod(keepAlive: true)
class FamilyDataNotifier extends _$FamilyDataNotifier {
  /// Язык интерфейса, для которого загружен архив.
  String get _localeCode => ref.read(appLocaleProvider).languageCode;

  @override
  Future<FamilyData> build() async {
    // Смена языка перезагружает архив этого языка.
    final localeName = ref.watch(appLocaleProvider).languageCode;
    return ref
        .watch(familyRepositoryProvider)
        .loadFamilyData(localeName: localeName);
  }

  void updateMember(
    String id,
    FamilyMember Function(FamilyMember) transform,
  ) {
    _update(
      (data) => data.copyWith(
        members: data.members
            .map((member) => member.id == id ? transform(member) : member)
            .toList(growable: false),
      ),
    );
  }

  void addMember(FamilyMember member) {
    _update(
      (data) => data.copyWith(
        members: [...data.members, member],
      ),
    );
  }

  void removeMember(String id) {
    _update(
      (data) => data.copyWith(
        members: data.members
            .where((member) => member.id != id)
            .map(_withoutPersonInMember(id))
            .toList(growable: false),
        timelineEvents: data.timelineEvents
            .where((event) => event.memberId != id)
            .map(_withoutPersonInEvent(id))
            .toList(growable: false),
      ),
    );
  }

  void updateTimelineEvent(
    String id,
    TimelineEvent Function(TimelineEvent) transform,
  ) {
    _update((data) {
      final events = data.timelineEvents
          .map((event) => event.id == id ? transform(event) : event)
          .toList(growable: false)
        ..sort((a, b) => a.date.compareTo(b.date));
      return data.copyWith(timelineEvents: events);
    });
  }

  void addTimelineEvent(TimelineEvent event) {
    _update((data) {
      final events = [...data.timelineEvents, event]
        ..sort((a, b) => a.date.compareTo(b.date));
      return data.copyWith(timelineEvents: events);
    });
  }

  void removeTimelineEvent(String id) {
    _update(
      (data) => data.copyWith(
        timelineEvents: data.timelineEvents
            .where((event) => event.id != id)
            .toList(growable: false),
      ),
    );
  }

  void updateSettings(FamilySettings settings) {
    _update((data) => data.copyWith(settings: settings));
  }

  /// Добавляет или заменяет файл в общей медиатеке.
  void upsertMediaAsset(MediaAsset asset) {
    _update((data) => data.withUpdatedMediaAsset(asset));
  }

  /// Удаляет файл из медиатеки и все его связи.
  void removeMediaAsset(String assetId) {
    _update((data) => data.withoutMediaAsset(assetId));
  }

  /// Заменяет данные целиком — используется восстановлением из копии.
  void replaceData(FamilyData data) {
    final normalized = data.normalizeMediaLibrary();
    state = AsyncData(normalized);
    unawaited(_save(normalized));
  }

  /// Возвращает данные к исходному архиву.
  void reset() {
    ref.invalidateSelf();
  }

  void _update(FamilyData Function(FamilyData) transform) {
    final current = state.value;
    if (current == null) return;
    final next = transform(current).normalizeMediaLibrary();
    state = AsyncData(next);
    unawaited(_save(next));
  }

  Future<void> _save(FamilyData data) {
    return ref
        .read(familyRepositoryProvider)
        .saveFamilyData(data, localeName: _localeCode);
  }
}

FamilyMember Function(FamilyMember) _withoutPersonInMember(String personId) {
  return (member) => member.copyWith(
        birthdayMedia: member.birthdayMedia
            .map((media) => _withoutPersonInMedia(media, personId))
            .toList(growable: false),
        gallery: member.gallery
            .map(
              (shot) => shot.copyWith(
                media: shot.media
                    .map((media) => _withoutPersonInMedia(media, personId))
                    .toList(growable: false),
              ),
            )
            .toList(growable: false),
      );
}

TimelineEvent Function(TimelineEvent) _withoutPersonInEvent(String personId) {
  return (event) => event.copyWith(
        media: event.media
            .map((media) => _withoutPersonInMedia(media, personId))
            .toList(growable: false),
      );
}

FamilyMedia _withoutPersonInMedia(FamilyMedia media, String personId) {
  return media.copyWith(
    people: media.people
        .where((person) => person.id != personId)
        .toList(growable: false),
  );
}
