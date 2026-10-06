import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_article.dart';

/// Injects and executes DOM reader parsing scripts on the active WebView.
class ReaderExtractor {
  /// JavaScript script to extract clean article structure from DOM.
  static const String extractionScript = '''
(function() {
  try {
    const title = document.querySelector('h1')?.innerText || document.title || 'Untitled';
    
    // Attempt to locate main article content container
    let articleEl = document.querySelector('article') ||
                    document.querySelector('main') ||
                    document.querySelector('.article-body') ||
                    document.querySelector('.post-content') ||
                    document.querySelector('.entry-content') ||
                    document.body;

    // Clone to manipulate without altering live page DOM
    const clone = articleEl.cloneNode(true);

    // Remove noise elements
    const noiseSelectors = [
      'nav', 'header', 'footer', 'aside', 'form', 'button',
      '.ad', '.ads', '.advertisement', '.social-share',
      '.comments', '.related-posts', 'script', 'style', 'iframe'
    ];
    noiseSelectors.forEach(sel => {
      clone.querySelectorAll(sel).forEach(el => el.remove());
    });

    // Extract byline if present
    const bylineEl = document.querySelector('.author') || 
                     document.querySelector('.byline') ||
                     document.querySelector('[rel="author"]');
    const byline = bylineEl ? bylineEl.innerText.trim() : null;

    // Collect clean paragraphs
    const paragraphs = Array.from(clone.querySelectorAll('p, h2, h3, blockquote, ul, ol, img'))
      .map(node => node.outerHTML)
      .join('');

    const textContent = clone.innerText || '';

    return JSON.stringify({
      title: title.trim(),
      byline: byline,
      excerpt: textContent.slice(0, 200).trim() + '...',
      contentHtml: paragraphs.length > 50 ? paragraphs : clone.innerHTML,
      textContent: textContent.trim(),
      url: window.location.href,
      extractedAt: new Date().toISOString()
    });
  } catch (e) {
    return JSON.stringify({ error: e.toString() });
  }
})();
''';

  /// Extracts ReaderArticle from the currently loaded page in InAppWebViewController.
  static Future<ReaderArticle?> extractFromWebView(
    InAppWebViewController? controller,
  ) async {
    if (controller == null) return null;

    try {
      final result = await controller.evaluateJavascript(
        source: extractionScript,
      );
      if (result != null && result is String && result.isNotEmpty) {
        final decoded = json.decode(result) as Map<String, dynamic>;
        if (decoded.containsKey('error')) return null;
        return ReaderArticle.fromMap(decoded);
      }
    } catch (_) {
      // JS evaluation error
    }
    return null;
  }
}
