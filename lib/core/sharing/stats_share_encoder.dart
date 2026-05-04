// ============================================================
// Fichier : lib/core/sharing/stats_share_encoder.dart
// Description : Encodeur/décodeur d'un snapshot de statistiques
//               pour partage via URL orphotonie://stats?d=ORPH-STAT-...
//               Format JSON minimal compressé GZip + Base64.
//               100 % hors-ligne — aucune donnée envoyée sur le réseau.
// ============================================================

import 'dart:convert';

import 'package:archive/archive.dart';

import '../../features/stats/data/stats_repository.dart';
import 'share_encoder.dart';

// ---------------------------------------------------------------------------
// Modèle du snapshot de statistiques
// ---------------------------------------------------------------------------

/// Snapshot minimal d'une période de statistiques d'un enfant.
///
/// Conçu pour tenir dans une URL (< 2 000 caractères après compression).
/// Les données de heatmap (365 jours) sont exclues pour respecter la limite.
class StatsSnapshot {
  factory StatsSnapshot.fromJson(Map<String, dynamic> json) {
    return StatsSnapshot(
      childName: json['n'] as String? ?? '?',
      period: json['p'] as String? ?? 'month',
      exportDate: json['dt'] as String? ?? '',
      totalWordsSeen: json['ts'] as int? ?? 0,
      totalWordsSuccess: json['tss'] as int? ?? 0,
      globalSuccessRate: double.tryParse(
            (json['r'] ?? '0').toString(),
          ) ??
          0.0,
      wordsMastered: json['m'] as int? ?? 0,
      wordsInProgress: json['ip'] as int? ?? 0,
      currentStreak: json['s'] as int? ?? 0,
      activityStats: (json['a'] as List<dynamic>? ?? [])
          .map((e) => ActivitySnapshotStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficultWords:
          (json['d'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
    );
  }
  const StatsSnapshot({
    required this.childName,
    required this.period,
    required this.exportDate,
    required this.totalWordsSeen,
    required this.totalWordsSuccess,
    required this.globalSuccessRate,
    required this.wordsMastered,
    required this.wordsInProgress,
    required this.currentStreak,
    required this.activityStats,
    required this.difficultWords,
  });

  /// Prénom de l'enfant.
  final String childName;

  /// Période (week / month / all).
  final String period;

  /// Date d'export (YYYY-MM-DD).
  final String exportDate;

  final int totalWordsSeen;
  final int totalWordsSuccess;
  final double globalSuccessRate;
  final int wordsMastered;
  final int wordsInProgress;
  final int currentStreak;

  /// Taux par activité (anagramme, pendu, etc.).
  final List<ActivitySnapshotStat> activityStats;

  /// Top 5 mots difficiles.
  final List<String> difficultWords;

  Map<String, dynamic> toJson() => {
        'n': childName,
        'p': period,
        'dt': exportDate,
        'ts': totalWordsSeen,
        'tss': totalWordsSuccess,
        'r': globalSuccessRate.toStringAsFixed(1),
        'm': wordsMastered,
        'ip': wordsInProgress,
        's': currentStreak,
        'a': activityStats.map((a) => a.toJson()).toList(),
        'd': difficultWords,
      };
}

/// Stats d'une activité dans le snapshot.
class ActivitySnapshotStat {
  factory ActivitySnapshotStat.fromJson(Map<String, dynamic> json) =>
      ActivitySnapshotStat(
        activityType: json['t'] as String? ?? '?',
        totalAttempts: json['n'] as int? ?? 0,
        successes: json['s'] as int? ?? 0,
      );
  const ActivitySnapshotStat({
    required this.activityType,
    required this.totalAttempts,
    required this.successes,
  });

  final String activityType;
  final int totalAttempts;
  final int successes;

  double get successRate =>
      totalAttempts > 0 ? (successes / totalAttempts) * 100 : 0;

  Map<String, dynamic> toJson() => {
        't': activityType,
        'n': totalAttempts,
        's': successes,
      };
}

// ---------------------------------------------------------------------------
// Encodeur / décodeur
// ---------------------------------------------------------------------------

/// Service d'encodage/décodage de snapshots de statistiques.
class StatsShareEncoder {
  /// Convertit un [ProgressSummary] en [StatsSnapshot] exportable.
  StatsSnapshot summaryToSnapshot({
    required ProgressSummary summary,
    required String childName,
    required StatsPeriod period,
  }) {
    return StatsSnapshot(
      childName: childName,
      period: period.name,
      exportDate: DateTime.now().toIso8601String().substring(0, 10),
      totalWordsSeen: summary.totalWordsSeen,
      totalWordsSuccess: summary.totalWordsSuccess,
      globalSuccessRate: summary.globalSuccessRate,
      wordsMastered: summary.wordsMastered,
      wordsInProgress: summary.wordsInProgress,
      currentStreak: summary.currentStreak,
      activityStats: summary.activityStats
          .map(
            (a) => ActivitySnapshotStat(
              activityType: a.activityType,
              totalAttempts: a.totalAttempts,
              successes: a.successes,
            ),
          )
          .toList(),
      // Top 5 mots difficiles seulement (pour rester dans la limite URL)
      difficultWords: summary.difficultWords.take(5).map((w) => w.mot).toList(),
    );
  }

  /// Encode un snapshot en code `ORPH-STAT-[base64gzip]`.
  String encodeSnapshot(StatsSnapshot snapshot) {
    final json = jsonEncode(snapshot.toJson());
    final gzipped = GZipEncoder().encode(utf8.encode(json));
    final b64 = base64Encode(gzipped!);
    return '$kOrphStatPrefix$b64';
  }

  /// Génère l'URL de partage `orphotonie://stats?d=ORPH-STAT-...`.
  String generateStatsUrl(StatsSnapshot snapshot) {
    final code = encodeSnapshot(snapshot);
    return Uri(
      scheme: kOrphScheme,
      host: kOrphStatsHost,
      queryParameters: {kOrphDataParam: code},
    ).toString();
  }

  /// Décode un code `ORPH-STAT-...` en [StatsSnapshot].
  StatsSnapshot decodeSnapshot(String code) {
    final trimmed = code.trim();
    if (!trimmed.startsWith(kOrphStatPrefix)) {
      throw const FormatException(
        'Code invalide : doit commencer par "ORPH-STAT-".',
      );
    }

    final b64 = trimmed.substring(kOrphStatPrefix.length);

    List<int> gzipped;
    try {
      gzipped = base64Decode(b64);
    } catch (_) {
      throw const FormatException(
        'Code ORPH-STAT- invalide : base64 corrompu.',
      );
    }

    String jsonString;
    try {
      jsonString = utf8.decode(GZipDecoder().decodeBytes(gzipped));
    } catch (_) {
      throw const FormatException(
        'Code ORPH-STAT- invalide : données corrompues.',
      );
    }

    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Code ORPH-STAT- invalide : JSON malformé.');
    }

    return StatsSnapshot.fromJson(jsonData);
  }

  /// Extrait et décode un snapshot depuis une URL `orphotonie://stats?d=...`.
  StatsSnapshot? decodeFromUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      if (uri.scheme == kOrphScheme && uri.host == kOrphStatsHost) {
        final d = uri.queryParameters[kOrphDataParam];
        if (d != null) return decodeSnapshot(d);
      }
    } catch (_) {}
    return null;
  }
}
