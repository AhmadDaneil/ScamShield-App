import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';
import 'package:uuid/uuid.dart';
 
class ModelService extends ChangeNotifier {
  // ── Config ─────────────────────────────────────────────────────────────────
  // Change this to your deployed API URL for production.
  // For local development use your machine's LAN IP (not localhost —
  // Android emulator can't reach localhost of host machine).
  //   Emulator  → "http://10.0.2.2:5000"
  //   Real device on same WiFi → "http://192.168.x.x:5000"
  //   Deployed  → "https://your-api.com"
  static const String _baseUrl = "http://10.62.48.163:5000";
 
  bool _isLoaded = false;
  bool _hasError = false;
  String? _errorMessage;
 
  bool get isLoaded      => _isLoaded;
  bool get hasError      => _hasError;
  String? get errorMessage => _errorMessage;
 
  // ── Initialize — just verify the API is reachable ─────────────────────────
  Future<void> loadModel() async {
    debugPrint("📦 Checking API health...");
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/health"))
          .timeout(const Duration(seconds: 10));
 
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        debugPrint("✅ API ready — device: ${body['device']}");
        _isLoaded  = true;
        _hasError  = false;
        _errorMessage = null;
      } else {
        throw Exception("API returned status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ API health check failed: $e");
      _hasError     = true;
      _errorMessage = e.toString();
      _isLoaded     = false;
    }
    notifyListeners();
  }
 
  // ── Predict ────────────────────────────────────────────────────────────────
  Future<ScanResult> predict(String rawText) async {
    debugPrint("🔥 predict() called, isLoaded=$_isLoaded");
 
    if (!_isLoaded) {
      throw Exception('API not ready — please check your connection');
    }
 
    final t0 = DateTime.now();
 
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/predict"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": rawText}),
          )
          .timeout(const Duration(seconds: 30));
 
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body["error"] ?? "API error ${response.statusCode}");
      }
 
      final data       = jsonDecode(response.body);
      final isFake     = data["is_fake"]    as bool;
      final fakeScore  = (data["fake_score"] as num).toDouble();
      final realScore  = (data["real_score"] as num).toDouble();
      final confidence = (data["confidence"] as num).toDouble();
      final elapsedMs  = data["elapsed_ms"] as int;
 
      debugPrint("✅ Prediction: ${data['label']} "
          "(fake=$fakeScore, real=$realScore) "
          "in ${DateTime.now().difference(t0).inMilliseconds}ms "
          "(server: ${elapsedMs}ms)");
 
      return ScanResult(
        id:         const Uuid().v4(),
        text:       rawText,
        isFake:     isFake,
        confidence: confidence,
        timestamp:  DateTime.now(),
      );
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint("❌ predict() error: $e");
      rethrow;
    }
  }
 
  @override
  void dispose() {
    super.dispose();
  }
}
 