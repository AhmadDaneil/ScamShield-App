import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_result.dart';
import '../utils/text_cleaner.dart';
import 'tokenizer_service.dart';

class ModelService extends ChangeNotifier {
  ModelObjectDetection? _model;
  final TokenizerService _tokenizer = TokenizerService();
  bool _isLoaded = false;

  final List<double> _featureMean = [
    116.5,
    0.8,
    0.3,
    0.05,
    0.1,
    0.02,
  ];

  final List<double> _featureStd = [
    98.2,
    2.1,
    1.0,
    0.04,
    0.5,
    0.03,
  ];

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      await _tokenizer.load();

      _model = await PytorchLite.loadObjectDetectionModel(
        'assets/models/scamshield_model.ptl',
        2,
        128,
        128,
      );

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Model loading error: $e');
    }
  }

  Future<ScanResult> predict(String rawText) async {
    if (!_isLoaded || _model == null) {
      throw Exception('Model not loaded');
    }
    final cleanedText = TextCleaner.clean(rawText);

    final tokens = _tokenizer.tokenize(cleanedText);
    final inputIds = tokens['input_ids']!;
    final attentionMask = tokens['attention_mask']!;

    final rawFeatures = TextCleaner.extractFeatures(cleanedText);
    final normalizedFeatures = _normalizeFeatures(rawFeatures);

    final inputIdsFloat = inputIds.map((e) => e.toDouble()).toList();
    final maskFloat =  attentionMask.map((e) => e.toDouble()).toList();

    final output = await _model!.getImagePrediction(
      inputIdsFloat,
      maskFloat,
      normalizedFeatures,
    );

    final scores = _softmax(output ?? [0.5, 0.5]);

    final fakeScore = scores[0];
    final realScore = scores[1];
    final isFake = fakeScore > realScore;
    final confidence = isFake ? fakeScore : realScore;

    return ScanResult(
      id: const Uuid().v4(),
      text: rawText,
      isFake: isFake,
      confidence: confidence,
      timepstamp: DateTime.now(),
    );
  }

  List<double> _normalizeFeatures(List<double> features) {
    final normalized = <double>[];
    for (int i = 0; i < features.length; i++) {
      final std = _featureStd[i] < 1e-8 ? 1e-8 : _featureStd[i];
      normalized.add((features[i] - _featureMean[i]) / std);
    }
    return normalized;
  }

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(max);
    final exps = logits.reduce(max);
    final sumExp = exps.reduce((a,b) => a+ b);
    return exps.map((e) => e / sumExps).toList();
  }
}