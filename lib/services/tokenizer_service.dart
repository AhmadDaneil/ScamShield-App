// lib/services/tokenizer_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TokenizerService {
  static const int maxLength = 128;
  static const int padTokenId = 0;
  static const int unkTokenId = 100;
  static const int clsTokenId = 101;
  static const int sepTokenId = 102;

  Map<String, int> _vocab = {};
  bool _isLoaded = false;

  Future<void> load() async {
  if (_isLoaded) return;

  final raw = await rootBundle.loadString('assets/vocab/vocab.txt');
  final lines = raw.split('\n');

  int tokenId = 0;                          // ← separate counter
  for (final line in lines) {
    final token = line.trim();
    if (token.isNotEmpty) {
      _vocab[token] = tokenId;
      tokenId++;                            // ← only increments for real tokens
    }
  }

  debugPrint('✅ Vocab loaded: $tokenId tokens');

  // Sanity check — these must match DistilBERT distilbert-base-uncased
  assert(_vocab['[PAD]']  == 0,   '[PAD] should be 0,   got ${_vocab['[PAD]']}');
  assert(_vocab['[UNK]']  == 100, '[UNK] should be 100, got ${_vocab['[UNK]']}');
  assert(_vocab['[CLS]']  == 101, '[CLS] should be 101, got ${_vocab['[CLS]']}');
  assert(_vocab['[SEP]']  == 102, '[SEP] should be 102, got ${_vocab['[SEP]']}');
  assert(tokenId          == 30522, 'Vocab size should be 30522, got $tokenId');

  _isLoaded = true;
}

  // Tokenize text into input_ids and attention_mask
  Map<String, List<int>> tokenize(String text) {
    // Basic WordPiece tokenization
    final tokens = _wordpieceTokenize(text);

    // Truncate to maxLength - 2 (for CLS and SEP)
    final truncated = tokens.length > maxLength - 2
        ? tokens.sublist(0, maxLength - 2)
        : tokens;

    // Add CLS and SEP
    final inputIds = [clsTokenId, ...truncated, sepTokenId];

    // Build attention mask (1 for real tokens)
    final attentionMask = List<int>.filled(inputIds.length, 1);

    // Pad to maxLength
    while (inputIds.length < maxLength) {
      inputIds.add(padTokenId);
      attentionMask.add(0);
    }

    return {
      'input_ids': inputIds,
      'attention_mask': attentionMask,
    };
  }

  List<int> _wordpieceTokenize(String text) {
    final List<int> tokenIds = [];
    final words = text.split(' ');

    for (final word in words) {
      if (word.isEmpty) continue;

      // Check full word first
      if (_vocab.containsKey(word)) {
        tokenIds.add(_vocab[word]!);
        continue;
      }

      // Try subword tokenization
      bool isBad = false;
      int start = 0;
      final List<int> subTokens = [];

      while (start < word.length) {
        int end = word.length;
        int? curSubstringId;

        while (start < end) {
          String substr = word.substring(start, end);
          if (start > 0) substr = '##$substr';

          if (_vocab.containsKey(substr)) {
            curSubstringId = _vocab[substr];
            break;
          }
          end--;
        }

        if (curSubstringId == null) {
          isBad = true;
          break;
        }

        subTokens.add(curSubstringId);
        start = end;
      }

      if (isBad) {
        tokenIds.add(unkTokenId);
      } else {
        tokenIds.addAll(subTokens);
      }
    }

    return tokenIds;
  }
}