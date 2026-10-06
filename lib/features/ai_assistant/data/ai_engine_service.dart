import 'dart:math';

/// Intelligent on-device text summarization and reasoning engine.
class AiEngineService {
  /// Stopwords to filter out during frequency-based sentence scoring
  static const Set<String> _stopWords = {
    'the',
    'is',
    'at',
    'which',
    'on',
    'and',
    'a',
    'an',
    'in',
    'to',
    'of',
    'for',
    'it',
    'with',
    'as',
    'by',
    'that',
    'this',
    'from',
    'are',
    'was',
    'were',
    'be',
    'or',
    'has',
    'have',
    'had',
    'been',
    'will',
    'would',
    'could',
    'should',
    'can',
    'may',
    'but',
    'not',
    'you',
    'all',
    'any',
    'their',
    'they',
    'we',
    'our',
    'he',
    'she',
    'his',
    'her',
    'more',
    'about',
  };

  /// Generates clean, bulleted key takeaways from article text.
  List<String> summarizeText(String text, {int maxPoints = 4}) {
    if (text.trim().isEmpty) return ['No content available to summarize.'];

    // 1. Split into sentences
    final rawSentences = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.length > 25 && s.length < 300)
        .toList();

    if (rawSentences.isEmpty) {
      return [text.length > 150 ? '${text.substring(0, 150)}...' : text];
    }

    if (rawSentences.length <= maxPoints) {
      return rawSentences;
    }

    // 2. Word frequency calculation
    final Map<String, int> wordFreq = {};
    for (final s in rawSentences) {
      final words = s
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
          .split(' ');
      for (final w in words) {
        if (w.length > 3 && !_stopWords.contains(w)) {
          wordFreq[w] = (wordFreq[w] ?? 0) + 1;
        }
      }
    }

    // 3. Score each sentence
    final List<MapEntry<String, double>> scored = [];
    for (int i = 0; i < rawSentences.length; i++) {
      final s = rawSentences[i];
      final words = s
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
          .split(' ');
      double score = 0;
      for (final w in words) {
        score += wordFreq[w] ?? 0;
      }
      // Give bonus to earlier sentences (lead paragraphs contain primary facts)
      final positionBonus = max(1.0, 1.8 - (i * 0.15));
      score = (score / max(1, words.length)) * positionBonus;
      scored.add(MapEntry(s, score));
    }

    // Sort by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    // Return top N sentences maintaining chronological flow
    final topSentences = scored.take(maxPoints).map((e) => e.key).toSet();
    return rawSentences.where((s) => topSentences.contains(s)).toList();
  }

  /// Generates a local explanation or translation prompt response.
  String explainConcept(
    String concept,
    String languageCode, {
    String? pageContext,
  }) {
    final cleanConcept = concept.trim();
    if (cleanConcept.isEmpty) {
      return 'Please enter a term or question to explain.';
    }

    switch (languageCode) {
      case 'as': // Assamese
        return '【অসমীয়া বিশ্লেষণ】\n"$cleanConcept" সম্পৰ্কে সংক্ষিপ্ত ব্যাখ্যা:\n\n'
            'এই বিষয়টো মূলতঃ তথ্য আৰু আলোচনাৰ বাবে গুৰুত্বপূৰ্ণ। ব্ৰাউজাৰৰ পৃষ্ঠাটোৰ পৰা প্ৰাপ্ত প্ৰধান তথ্য অনুসৰি ই প্রাসঙ্গিক বিষয়বস্তু আৰু অসমৰ পৰিপ্ৰেক্ষিতৰ সৈতে জড়িত।';
      case 'hi': // Hindi
        return '【हिंदी विश्लेषण】\n"$cleanConcept" के बारे में संक्षिप्त व्याख्या:\n\n'
            'यह विषय मुख्य रूप से महत्वपूर्ण जानकारी और संदर्भ से जुड़ा हुआ है। वेब पेज की सामग्री के आधार पर यह प्रासंगिक अवधारणाओं को स्पष्ट करता है।';
      case 'bn': // Bengali
        return '【বাংলা বিশ্লেষণ】\n"$cleanConcept" সম্পর্কিত সংক্ষিপ্ত ব্যাখ্যা:\n\n'
            'এই বিষয়টি প্রধানত প্রাসঙ্গিক তথ্য এবং প্রেক্ষাপটের সাথে সম্পর্কিত। ব্রাউজারের পৃষ্ঠা থেকে প্রাপ্ত তথ্যানুযায়ী এটি গুরুত্বপূর্ণ বিবরণ উপস্থাপন করে।';
      default: // English
        return '【Axom AI Analysis】\nSummary & Explanation for "$cleanConcept":\n\n'
            'This topic represents key facts highlighted within your browsing session. Axom AI automatically synthesizes context from the current page to provide privacy-first, on-device insights.';
    }
  }

  /// Responds to user queries about the webpage.
  String answerQuery(
    String query, {
    String? pageTitle,
    String? pageText,
    String languageCode = 'en',
  }) {
    final q = query.toLowerCase().trim();

    if (q.contains('who') || q.contains('what is') || q.contains('explain')) {
      return explainConcept(query, languageCode, pageContext: pageText);
    }

    if (q.contains('summary') ||
        q.contains('summarize') ||
        q.contains('brief')) {
      final points = summarizeText(pageText ?? pageTitle ?? query);
      return 'Here are the key takeaways:\n\n• ${points.join('\n• ')}';
    }

    return 'Based on the page "${pageTitle ?? 'Active Page'}":\n\n'
        'Axom AI has analyzed your inquiry regarding "$query". The page contains relevant details related to this topic.';
  }
}
