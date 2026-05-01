import 'dart:math';

abstract class SemanticSimilarityService {
  double compare(String reference, String answer);
}

class LocalSemanticSimilarityService implements SemanticSimilarityService {
  static const Map<String, List<String>> _synonyms = <String, List<String>>{
    'كحلي': <String>['ازرق غامق', 'ازرق داكن', 'navy', 'dark blue'],
    'اسود': <String>['black', 'غ امق جدا'],
    'ابيض': <String>['white'],
  };

  @override
  double compare(String reference, String answer) {
    final String normalizedReference = _normalize(reference);
    final String normalizedAnswer = _normalize(answer);

    if (normalizedReference == normalizedAnswer) {
      return 1;
    }

    final Set<String> referenceTokens = _expandTokens(normalizedReference);
    final Set<String> answerTokens = _expandTokens(normalizedAnswer);

    if (referenceTokens.isEmpty || answerTokens.isEmpty) {
      return 0;
    }

    final int overlap =
        referenceTokens.intersection(answerTokens).length;
    final int union = referenceTokens.union(answerTokens).length;
    final double jaccard = union == 0 ? 0 : overlap / union;

    final bool partialContainment =
        normalizedReference.contains(normalizedAnswer) ||
            normalizedAnswer.contains(normalizedReference);
    final double containmentBoost = partialContainment ? 0.2 : 0;

    return min(1, (jaccard * 0.85) + containmentBoost);
  }

  String _normalize(String value) {
    String text = value.toLowerCase().trim();
    text = text
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (text.contains('ازرق غامق') || text.contains('ازرق داكن')) {
      text = '$text كحلي';
    }

    return text;
  }

  Set<String> _expandTokens(String input) {
    final List<String> tokens = input.split(' ')
      ..removeWhere((String token) => token.isEmpty);
    final Set<String> expanded = <String>{...tokens};

    for (final MapEntry<String, List<String>> entry in _synonyms.entries) {
      final String key = entry.key;
      final List<String> values = entry.value;

      final bool containsAny = expanded.contains(key) ||
          values.any((String value) => input.contains(_normalize(value)));
      if (containsAny) {
        expanded.add(key);
        expanded.addAll(values.map(_normalize));
      }
    }

    return expanded;
  }
}

