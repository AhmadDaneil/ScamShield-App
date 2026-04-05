// lib/services/model_service.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/scan_result.dart';
import '../utils/text_cleaner.dart';
import 'tokenizer_service.dart';

class ModelService extends ChangeNotifier {
  Interpreter? _interpreter;
  final TokenizerService _tokenizer = TokenizerService();
  bool _isLoaded = false;

  final List<double> _featureMean = [
    319.2340087890625, 
    0.30629757046699524, 
    0.4853785037994385, 
    0.0, 
    5.2002982556587085e-05, 
    0.008210545405745506
  ];

  final List<double> _featureStd = [
    349.07989501953125, 
    1.0457844734191895, 
    1.3806873559951782, 
    0.0, 
    0.009309545159339905, 
    0.01442260853946209
  ];

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      await _tokenizer.load();

      _interpreter = await Interpreter.fromAsset(
        'assets/models/scamshield_model.tflite',
        options: InterpreterOptions()..threads = 2,
      );

      _isLoaded = true;
      notifyListeners();
      debugPrint('✅ TFLite model loaded');
      _printTensorInfo();
    } catch (e) {
      debugPrint('❌ Model loading error: $e');
    }
  }

  void _printTensorInfo() {
    if (_interpreter == null) return;
    debugPrint('Input tensors:');
    for (final t in _interpreter!.getInputTensors()) {
      debugPrint('  ${t.name}: ${t.shape} ${t.type}');
    }
    debugPrint('Output tensors:');
    for (final t in _interpreter!.getOutputTensors()) {
      debugPrint('  ${t.name}: ${t.shape} ${t.type}');
    }
  }

  Future<ScanResult> predict(String rawText) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('Model not loaded');
    }

    // Step 1 — Clean and tokenize
    final cleanedText = TextCleaner.clean(rawText);
    final tokens      = _tokenizer.tokenize(cleanedText);
    final inputIds    = tokens['input_ids']!;
    final mask        = tokens['attention_mask']!;

    // Step 2 — Extract and normalize features
    final rawFeatures = TextCleaner.extractFeatures(cleanedText);
    final features    = _normalizeFeatures(rawFeatures);

    // Step 3 — Prepare inputs
    // Shape [1, 128] for input_ids and attention_mask
    final inputIdsInput = [inputIds];
    final maskInput     = [mask];
    // Shape [1, 6] for features
    final featuresInput = [features];

    // Step 4 — Prepare output [1, 2]
    final output = List.filled(2, 0.0).reshape([1, 2]);

    // Step 5 — Run inference
    // ⚠️ Update indices below based on check_tflite_inputs.py output
    _interpreter!.runForMultipleInputs(
      [inputIdsInput, maskInput, featuresInput],
      {0: output},
    );

    // Step 6 — Softmax
    final logits = [
      (output[0] as List)[0] as double,
      (output[0] as List)[1] as double,
    ];
    final scores     = _softmax(logits);
    final fakeScore  = scores[0];
    final realScore  = scores[1];
    final isFake     = fakeScore > realScore;
    final confidence = isFake ? fakeScore : realScore;

    return ScanResult(
      id:         const Uuid().v4(),
      text:       rawText,
      isFake:     isFake,
      confidence: confidence,
      timestamp:  DateTime.now(),
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
    final maxVal = logits.reduce(max);
    final exps   = logits.map((e) => exp(e - maxVal)).toList();
    final sum    = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}