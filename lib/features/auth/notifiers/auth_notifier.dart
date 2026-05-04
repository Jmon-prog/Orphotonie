// ============================================================
// Fichier : lib/features/auth/notifiers/auth_notifier.dart
// Description : Gestion de l'etat d'authentification avec Riverpod.
//               Sealed class Dart 3 pour les etats (pas de freezed).
//               PIN verrouille apres 3 tentatives incorrectes (60 s).
//               Question secrete pour reinitialiser le PIN oublie :
//               3 mauvaises reponses → meme verrouillage 60 s.
//               100% local - aucun reseau.
// ============================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../services/pin_service.dart';

// ---------------------------------------------------------------------------
// Etats d'authentification (sealed class Dart 3)
// ---------------------------------------------------------------------------

sealed class AuthState {
  const AuthState();
}

/// Aucun profil selectionne.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Un profil enfant est actif - acces libre, sans PIN.
final class ChildSelected extends AuthState {
  const ChildSelected(this.profile);
  final Profile profile;
}

/// Le praticien est authentifie par PIN.
final class PractitionerAuth extends AuthState {
  const PractitionerAuth(this.profile);
  final Profile profile;
}

/// En attente de la saisie du PIN (avant validation).
final class AwaitingPin extends AuthState {
  const AwaitingPin(this.profile);
  final Profile profile;
}

/// En attente de la reponse a la question secrete (recuperation de PIN).
final class AwaitingSecretAnswer extends AuthState {
  const AwaitingSecretAnswer(this.profile);
  final Profile profile;
}

/// Reponse secrete correcte — le praticien peut definir un nouveau PIN.
final class PinResetAllowed extends AuthState {
  const PinResetAllowed(this.profile);
  final Profile profile;
}

/// PIN (ou question secrete) verrouille apres 3 echecs - secondes restantes.
final class PinLocked extends AuthState {
  const PinLocked(this.secondsLeft);
  final int secondsLeft;
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends Notifier<AuthState> {
  static const _maxAttempts = 3;
  static const _lockDuration = Duration(seconds: 60);

  int _failedAttempts = 0;
  Timer? _lockTimer;

  @override
  AuthState build() => const Unauthenticated();

  // --- Selection de profil enfant ---

  /// Selectionne un profil enfant et passe en mode jeu.
  void selectChild(Profile profile) {
    _failedAttempts = 0;
    state = ChildSelected(profile);
  }

  // --- Authentification praticien par PIN ---

  /// Indique qu'on attend le PIN pour ce profil praticien.
  void requestPinFor(Profile profile) {
    _failedAttempts = 0;
    state = AwaitingPin(profile);
  }

  /// Verifie le PIN entre par le praticien.
  /// Retourne true si correct, false sinon.
  Future<bool> submitPin(String pin) async {
    final pinService = ref.read(pinServiceProvider);

    // Aucun PIN configure - acces direct (premier lancement praticien)
    final hasPinConfigured = await pinService.hasPin();
    if (!hasPinConfigured) {
      final awaitingState = state;
      if (awaitingState is AwaitingPin) {
        state = PractitionerAuth(awaitingState.profile);
      }
      return true;
    }

    final isCorrect = await pinService.verifyPin(pin);
    if (isCorrect) {
      _failedAttempts = 0;
      final awaitingState = state;
      if (awaitingState is AwaitingPin) {
        state = PractitionerAuth(awaitingState.profile);
      }
      return true;
    }

    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      _startLockdown();
    }
    return false;
  }

  // --- Recuperation de PIN par question secrete ---

  /// Passe en mode saisie de la question secrete pour ce profil.
  void requestSecretAnswer(Profile profile) {
    _failedAttempts = 0;
    state = AwaitingSecretAnswer(profile);
  }

  /// Verifie la reponse a la question secrete.
  /// Si correcte → PinResetAllowed ; si 3 echecs → verrouillage 60s.
  /// Retourne true si la reponse est correcte.
  Future<bool> submitSecretAnswer(String answer) async {
    final pinService = ref.read(pinServiceProvider);
    final isCorrect = await pinService.verifySecretAnswer(answer);

    if (isCorrect) {
      _failedAttempts = 0;
      final current = state;
      if (current is AwaitingSecretAnswer) {
        state = PinResetAllowed(current.profile);
      }
      return true;
    }

    _failedAttempts++;
    if (_failedAttempts >= _maxAttempts) {
      _startLockdown();
    }
    return false;
  }

  /// Appele apres avoir redefinit le PIN : retourne a l'ecran de saisie.
  void completePinReset(Profile profile) {
    _failedAttempts = 0;
    state = AwaitingPin(profile);
  }

  /// Authentifie directement le gestionnaire sans saisie de PIN.
  /// Appelé quand aucun PIN n'est configuré.
  void directLoginGestionnaire(Profile profile) {
    _failedAttempts = 0;
    state = PractitionerAuth(profile);
  }

  // --- Deconnexion ---

  /// Deconnecte le profil actif et retourne a la selection de profil.
  void logout() {
    _lockTimer?.cancel();
    _failedAttempts = 0;
    state = const Unauthenticated();
  }

  // --- Verrouillage ---

  void _startLockdown() {
    int secondsLeft = _lockDuration.inSeconds;
    state = PinLocked(secondsLeft);

    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        timer.cancel();
        _failedAttempts = 0;
        state = const Unauthenticated();
      } else {
        state = PinLocked(secondsLeft);
      }
    });
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Profil enfant actuellement selectionne (null si non connecte).
final currentChildProvider = Provider<Profile?>((ref) {
  final s = ref.watch(authNotifierProvider);
  return s is ChildSelected ? s.profile : null;
});

/// Profil praticien authentifie (null si non connecte).
final currentPractitionerProvider = Provider<Profile?>((ref) {
  final s = ref.watch(authNotifierProvider);
  return s is PractitionerAuth ? s.profile : null;
});
