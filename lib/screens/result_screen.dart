// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/scan_result.dart';
import '../utils/app_colors.dart';
import '../widgets/verdict_card.dart';
import '../widgets/confidence_bar.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detection Result'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Verdict Card
              VerdictCard(result: result)
                  .animate()
                  .fadeIn()
                  .scale(),

              const SizedBox(height: 20),

              // Confidence Bar
              ConfidenceBar(result: result)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 20),

              // Analyzed Text Card
              _buildTextCard()
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 20),

              // AI Summary Card
              _buildAISummaryCard()
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 20),

              // Timestamp
              _buildTimestamp()
                  .animate()
                  .fadeIn(delay: 500.ms),

              const SizedBox(height: 20),

              // Analyze Another Button
              _buildAnalyzeAnotherButton(context)
                  .animate()
                  .fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 18,
                color: AppColors.textSecond,
              ),
              SizedBox(width: 8),
              Text(
                'Analyzed Text',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.preview,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecond,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryCard() {
    final summaryText = result.isFake
        ? 'The AI model detected patterns commonly associated with misinformation, including potential emotional manipulation, sensational language, or writing styles inconsistent with factual reporting. Exercise caution with this content.'
        : 'The AI model found that this content exhibits characteristics consistent with factual reporting. The writing style, tone, and linguistic patterns align with credible news sources. However, always verify from multiple sources.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'AI Analysis Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summaryText,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecond,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Powered by DistilBERT + Bi-LSTM hybrid model',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    final formatted =
        DateFormat('dd MMM yyyy, hh:mm a').format(result.timestamp);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time,
          size: 14,
          color: AppColors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          'Analyzed on $formatted',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeAnotherButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text(
          'Analyze Another Text',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}