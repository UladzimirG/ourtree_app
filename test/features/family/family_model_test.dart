import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/auth/domain/models/user_role.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';
import 'package:ourtree_app/features/settings/domain/models/settings_models.dart';

void main() {
  const settings = FamilySettings(
    familyName: 'Our tree',
    familySubtitle: 'Since 2004',
  );

  FamilyModel buildFamily({
    PremiumStatus premium = const PremiumStatus.inactive(),
    List<String> memberIds = const ['user-1'],
  }) =>
      FamilyModel(
        id: 'f1b2c3d4-0000-4000-8000-000000000001',
        name: 'Our tree',
        ownerUserId: 'user-1',
        memberIds: memberIds,
        memberUids: const ['auth-1'],
        revision: 7,
        createdAt: 1700000000000,
        updatedAt: 1700000000500,
        premium: premium,
        settings: settings,
      );

  const lifetime = PremiumStatus(
    active: true,
    plan: PremiumPlan.lifetime,
    source: PremiumSource.telegram,
    purchasedAt: 1700000000000,
  );

  group('FamilyModel', () {
    test('survives a JSON round-trip', () {
      final family = buildFamily(premium: lifetime);

      final restored = FamilyModel.fromJson(
        jsonDecode(jsonEncode(family.toJson())).cast<String, dynamic>(),
      );

      expect(restored, family);
    });

    test('keeps settings and premium as nested maps', () {
      final json = buildFamily(premium: lifetime).toJson();

      expect(json['settings'], isA<Map<String, dynamic>>());
      expect(json['premium'], isA<Map<String, dynamic>>());
      expect((json['premium'] as Map)['plan'], 'lifetime');
      expect((json['premium'] as Map)['source'], 'telegram');
    });

    test('detects members by both local id and auth uid', () {
      final family = buildFamily();

      expect(family.isMember('user-1'), isTrue);
      expect(family.isMember('user-2'), isFalse);
      expect(family.isAuthMember('auth-1'), isTrue);
      expect(family.isAuthMember(''), isFalse);
      expect(family.isOwner('user-1'), isTrue);
    });

    test('premium is inactive before purchase and expired after the date', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final family = buildFamily();

      expect(family.premiumActiveAt(now), isFalse);
      expect(
        buildFamily(premium: lifetime).premiumActiveAt(now),
        isTrue,
      );

      final expired = PremiumStatus(
        active: true,
        plan: PremiumPlan.lifetime,
        purchasedAt: 1600000000000,
        expiresAt: 1690000000000,
      );
      expect(buildFamily(premium: expired).premiumActiveAt(now), isFalse);
    });

    test('free slots follow the member limit of the current plan', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

      expect(buildFamily().freeSlots(now: now), freeFamilyMemberLimit - 1);
      expect(
        buildFamily(premium: lifetime).freeSlots(now: now),
        premiumFamilyMemberLimit - 1,
      );
      expect(
        buildFamily(memberIds: const []).freeSlots(now: now),
        freeFamilyMemberLimit,
      );
    });

    test('created() fills owner lists and derives the family name', () {
      final family = FamilyModel.created(
        id: 'f-new',
        name: '  Ивановы  ',
        ownerUserId: 'user-1',
        ownerAuthUid: 'auth-1',
        now: 1700000000000,
      );

      expect(family.name, 'Ивановы');
      expect(family.ownerAuthUid, 'auth-1');
      expect(family.memberIds, <String>['user-1']);
      expect(family.memberUids, <String>['auth-1']);
      expect(family.revision, 1);
      expect(family.createdAt, 1700000000000);
      expect(family.settings.familyName, 'Ивановы');
      expect(family.isOwner('user-1'), isTrue);
      expect(family.isAuthMember('auth-1'), isTrue);
      expect(family.premium.active, isFalse);
    });

    test('created() falls back to the default family name', () {
      final family = FamilyModel.created(
        id: 'f',
        name: '   ',
        ownerUserId: 'user-1',
        ownerAuthUid: 'auth-1',
        now: 1,
      );

      expect(family.name, FamilySettings.fallbackName);
      expect(family.settings.familyName, FamilySettings.fallbackName);
    });

    test('ownerAuthUid survives a JSON round-trip', () {
      final family = buildFamily().copyWith(ownerAuthUid: 'auth-owner');

      final restored = FamilyModel.fromJson(
        jsonDecode(jsonEncode(family.toJson())).cast<String, dynamic>(),
      );

      expect(restored.ownerAuthUid, 'auth-owner');
      expect(restored, family);
    });
  });

  group('FamilyMembership', () {
    test('maps the owner role to the admin UI role', () {
      const membership = FamilyMembership(
        userId: 'user-1',
        authUid: 'auth-1',
        role: FamilyRole.owner,
      );

      expect(membership.isOwner, isTrue);
      expect(membership.role.toUserRole(), UserRole.admin);
      expect(membership.canSeePerson('person-1'), isTrue);
    });

    test('restricts visible people for a limited viewer', () {
      const membership = FamilyMembership(
        userId: 'user-2',
        authUid: 'auth-2',
        role: FamilyRole.viewer,
        allMembersVisible: false,
        visiblePersonIds: ['person-1'],
      );

      expect(membership.isOwner, isFalse);
      expect(membership.role.canEdit, isFalse);
      expect(membership.canSeePerson('person-1'), isTrue);
      expect(membership.canSeePerson('person-2'), isFalse);
    });

    test('owner() creates an active owner membership', () {
      final membership = FamilyMembership.owner(
        userId: 'user-1',
        authUid: 'auth-1',
        now: 1700000000000,
      );

      expect(membership.role, FamilyRole.owner);
      expect(membership.status, FamilyMembershipStatus.active);
      expect(membership.isOwner, isTrue);
      expect(membership.isActive, isTrue);
      expect(membership.updatedAt, 1700000000000);
      expect(membership.joinedAt, 1700000000000);
    });
  });
}
