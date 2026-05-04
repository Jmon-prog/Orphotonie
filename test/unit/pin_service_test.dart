// ============================================================
// Fichier : test/unit/pin_service_test.dart
// Description : Tests unitaires pour PinService et AuthNotifier.
//               FlutterSecureStorage mocké via mocktail.
// ============================================================

import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orphotonie/features/auth/services/pin_service.dart';
import 'package:orphotonie/features/auth/notifiers/auth_notifier.dart';
import 'package:orphotonie/core/database/app_database.dart';
import 'package:orphotonie/core/database/database_providers.dart';
import 'package:drift/native.dart';

// Mock de FlutterSecureStorage
class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage storage;
  late PinService pinService;

  setUp(() {
    storage = MockSecureStorage();
    pinService = PinService(storage);
  });

  group('PinService', () {
    test('hasPin() retourne false quand aucun hash stocké', () async {
      when(() => storage.read(key: 'orphotonie_pin_hash'))
          .thenAnswer((_) async => null);
      expect(await pinService.hasPin(), false);
    });

    test('hasPin() retourne true quand un hash est présent', () async {
      when(() => storage.read(key: 'orphotonie_pin_hash'))
          .thenAnswer((_) async => 'somehash');
      expect(await pinService.hasPin(), true);
    });

    test('setPin() écrit hash et salt dans le stockage sécurisé', () async {
      when(
        () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((_) async {});
      await pinService.setPin('1234');
      verify(
        () => storage.write(
          key: 'orphotonie_pin_hash',
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(
        () => storage.write(
          key: 'orphotonie_pin_salt',
          value: any(named: 'value'),
        ),
      ).called(1);
    });

    test('verifyPin() retourne true pour le bon PIN', () async {
      // Stocker un vrai PIN, puis le vérifier
      String? storedHash;
      String? storedSalt;

      when(
        () => storage.write(
          key: 'orphotonie_pin_hash',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedHash = i.namedArguments[const Symbol('value')] as String;
      });
      when(
        () => storage.write(
          key: 'orphotonie_pin_salt',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedSalt = i.namedArguments[const Symbol('value')] as String;
      });

      await pinService.setPin('4321');

      when(() => storage.read(key: 'orphotonie_pin_hash'))
          .thenAnswer((_) async => storedHash);
      when(() => storage.read(key: 'orphotonie_pin_salt'))
          .thenAnswer((_) async => storedSalt);

      expect(await pinService.verifyPin('4321'), true);
    });

    test('verifyPin() retourne false pour un mauvais PIN', () async {
      String? storedHash;
      String? storedSalt;

      when(
        () => storage.write(
          key: 'orphotonie_pin_hash',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedHash = i.namedArguments[const Symbol('value')] as String;
      });
      when(
        () => storage.write(
          key: 'orphotonie_pin_salt',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedSalt = i.namedArguments[const Symbol('value')] as String;
      });

      await pinService.setPin('1111');

      when(() => storage.read(key: 'orphotonie_pin_hash'))
          .thenAnswer((_) async => storedHash);
      when(() => storage.read(key: 'orphotonie_pin_salt'))
          .thenAnswer((_) async => storedSalt);

      expect(await pinService.verifyPin('9999'), false);
    });

    test('clearPin() supprime hash et salt', () async {
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      await pinService.clearPin();
      verify(() => storage.delete(key: 'orphotonie_pin_hash')).called(1);
      verify(() => storage.delete(key: 'orphotonie_pin_salt')).called(1);
    });
  });

  group('AuthNotifier', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          pinServiceProvider.overrideWithValue(pinService),
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
    }

    test('état initial est Unauthenticated', () {
      final container = makeContainer();
      addTearDown(container.dispose);
      expect(container.read(authNotifierProvider), isA<Unauthenticated>());
    });

    test('selectChild() passe à ChildSelected', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // Insérer un profil enfant
      final dao = db.profilesDao;
      final id = await dao.insertProfile(
        ProfilesCompanion.insert(prenom: 'Léa', type: const Value('enfant')),
      );
      final profile = await dao.getProfileById(id);

      container.read(authNotifierProvider.notifier).selectChild(profile!);
      final state = container.read(authNotifierProvider);
      expect(state, isA<ChildSelected>());
      expect((state as ChildSelected).profile.prenom, 'Léa');
    });

    test('logout() revient à Unauthenticated', () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      final dao = db.profilesDao;
      final id = await dao.insertProfile(
        ProfilesCompanion.insert(prenom: 'Tom', type: const Value('enfant')),
      );
      final profile = await dao.getProfileById(id);

      container.read(authNotifierProvider.notifier).selectChild(profile!);
      container.read(authNotifierProvider.notifier).logout();
      expect(container.read(authNotifierProvider), isA<Unauthenticated>());
    });

    test('submitPin() avec mauvais PIN après 3 tentatives déclenche PinLocked',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);

      // PIN stocké = '1234', on envoie des mauvais PIN
      String? storedHash;
      String? storedSalt;

      when(
        () => storage.write(
          key: 'orphotonie_pin_hash',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedHash = i.namedArguments[const Symbol('value')] as String;
      });
      when(
        () => storage.write(
          key: 'orphotonie_pin_salt',
          value: any(named: 'value'),
        ),
      ).thenAnswer((i) async {
        storedSalt = i.namedArguments[const Symbol('value')] as String;
      });
      await pinService.setPin('1234');

      when(() => storage.read(key: 'orphotonie_pin_hash'))
          .thenAnswer((_) async => storedHash);
      when(() => storage.read(key: 'orphotonie_pin_salt'))
          .thenAnswer((_) async => storedSalt);

      final dao = db.profilesDao;
      final id = await dao.insertProfile(
        ProfilesCompanion.insert(
          prenom: 'Dr Martin',
          type: const Value('praticien'),
        ),
      );
      final profile = await dao.getProfileById(id);

      container.read(authNotifierProvider.notifier).requestPinFor(profile!);

      // 3 mauvais PIN
      for (var i = 0; i < 3; i++) {
        await container.read(authNotifierProvider.notifier).submitPin('0000');
      }

      expect(container.read(authNotifierProvider), isA<PinLocked>());
    });
  });
}
