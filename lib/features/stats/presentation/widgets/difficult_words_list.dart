// ============================================================
// Fichier : lib/features/stats/presentation/widgets/difficult_words_list.dart
// Description : Liste des mots en difficulté (taux < 50%).
//               Mots difficiles en rouge, maîtrisés en vert.
//               Accessible.
// ============================================================

import 'package:flutter/material.dart';
import '../../data/stats_repository.dart';

/// Liste des mots difficiles avec taux de réussite.
class DifficultWordsList extends StatelessWidget {
  const DifficultWordsList({
    super.key,
    required this.words,
    this.onWordTap,
  });

  /// Mots en difficulté.
  final List<WordStats> words;

  /// Callback quand un mot est tapé (navigation vers le détail).
  final void Function(WordStats word)? onWordTap;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400),
            const SizedBox(width: 8),
            const Text('Aucun mot en difficulté !'),
          ],
        ),
      );
    }

    return Semantics(
      label: 'Liste des mots en difficulté',
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: words.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final word = words[index];
          return _DifficultWordTile(
            word: word,
            onTap: onWordTap != null ? () => onWordTap!(word) : null,
          );
        },
      ),
    );
  }
}

class _DifficultWordTile extends StatelessWidget {
  const _DifficultWordTile({
    required this.word,
    this.onTap,
  });

  final WordStats word;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rateColor = word.successRate < 30
        ? Colors.red
        : word.successRate < 50
            ? Colors.orange
            : Colors.green;

    return Semantics(
      button: onTap != null,
      label:
          '${word.mot}, ${word.nbSuccess} réussites sur ${word.nbSeen} essais'
          '${word.dictionaryName.isNotEmpty ? ", dictionnaire ${word.dictionaryName}" : ""}',
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: rateColor.withValues(alpha: 0.15),
          child: Text(
            '${word.successRate.round()}%',
            style: TextStyle(
              color: rateColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          word.mot,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${word.nbSuccess}/${word.nbSeen} réussites · Boîte ${word.leitnerBox}',
            ),
            if (word.dictionaryName.isNotEmpty)
              Text(
                word.dictionaryName,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
        isThreeLine: word.dictionaryName.isNotEmpty,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      ),
    );
  }
}
