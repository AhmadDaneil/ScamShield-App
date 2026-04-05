import 'package:equatable/equatable.dart';

class ScanResult extends Equatable {
  final String id;
  final String text;
  final bool isFake;
  final double confidence;
  final DateTime timestamp;

  const ScanResult({
    required this.id,
    required this.text,
    required this.isFake,
    required this.confidence,
    required this.timestamp,
  });

  // Label for display
  String get label => isFake ? 'FAKE NEWS' : 'REAL NEWS';

  // Confidence as percentage string
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  // Confidence level description
  String get confidenceLevel {
    if (confidence >= 0.85) return 'High Confidence';
    if (confidence >= 0.65) return 'Moderate Confidence';
    return 'Low Confidence';
  }

  // Short preview of text
  String get preview => text.length > 100
      ? '${text.substring(0, 100)}...'
      : text;

  // Convert to map for SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isFake': isFake ? 1 : 0,
        'confidence': confidence,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  // Create from SQLite map
  factory ScanResult.fromMap(Map<String, dynamic> map) => ScanResult(
        id: map['id'] as String,
        text: map['text'] as String,
        isFake: map['isFake'] == 1,
        confidence: map['confidence'] as double,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int,
        ),
      );

  // CopyWith
  ScanResult copyWith({
    String? id,
    String? text,
    bool? isFake,
    double? confidence,
    DateTime? timestamp,
  }) =>
      ScanResult(
        id: id ?? this.id,
        text: text ?? this.text,
        isFake: isFake ?? this.isFake,
        confidence: confidence ?? this.confidence,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  List<Object?> get props => [id, text, isFake, confidence, timestamp];

  @override
  String toString() =>
      'ScanResult(id: $id, isFake: $isFake, confidence: $confidence)';
}