import 'package:flutter_test/flutter_test.dart';
import 'package:ourtree_app/features/family/data/repositories/invite_store.dart';
import 'package:ourtree_app/features/family/domain/models/family_models.dart';

void main() {
  group('InviteCode', () {
    test('normalize strips separators and uppercases', () {
      expect(InviteCode.normalize(' ab2c-d3ef '), 'AB2CD3EF');
      expect(InviteCode.normalize('ab2c_d3ef'), 'AB2CD3EF');
      expect(InviteCode.normalize('AB2C\nD3EF'), 'AB2CD3EF');
    });

    test('generated codes are valid and use a safe alphabet', () {
      for (var i = 0; i < 50; i++) {
        final code = InviteCode.generate();
        expect(code, hasLength(InviteCode.length));
        expect(InviteCode.isValid(code), isTrue, reason: code);
        expect(code, isNot(contains(RegExp('[01OIL]'))), reason: code);
      }
    });

    test('rejects codes with wrong length or ambiguous characters', () {
      expect(InviteCode.isValid('AB2CD3E'), isFalse);
      expect(InviteCode.isValid('AB2CD3EFG'), isFalse);
      expect(InviteCode.isValid('AB2CD3E0'), isFalse);
      expect(InviteCode.isValid('ab2cd3ef'), isFalse);
      expect(InviteCode.isValid('AB2CD3EI'), isFalse);
    });
  });

  group('InviteInfo', () {
    final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    InviteInfo invite({int? expiresAt, bool revoked = false}) => InviteInfo(
          code: 'AB2CD3EF',
          familyId: 'family-1',
          revoked: revoked,
          expiresAt: expiresAt ?? now.millisecondsSinceEpoch + 1000,
        );

    test('is valid before the expiration date', () {
      expect(invite().isValidAt(now), isTrue);
    });

    test('is invalid once expired', () {
      final expired = invite(expiresAt: now.millisecondsSinceEpoch - 1);
      expect(expired.isExpiredAt(now), isTrue);
      expect(expired.isValidAt(now), isFalse);
    });

    test('is invalid when revoked', () {
      expect(invite(revoked: true).isValidAt(now), isFalse);
    });

    test('parses the Firestore document', () {
      final info = InviteInfo.fromJson('AB2CD3EF', {
        'familyId': 'family-9',
        'expiresAt': 1700000005000,
        'revoked': false,
      });

      expect(info.code, 'AB2CD3EF');
      expect(info.familyId, 'family-9');
      expect(info.expiresAt, 1700000005000);
      expect(info.isValidAt(now), isTrue);
    });
  });
}
