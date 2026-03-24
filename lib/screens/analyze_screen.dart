// lib/screens/analyze_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubits/scan/scan_cubit.dart';
import '../cubits/scan/scan_state.dart';
import '../utils/app_colors.dart';
import 'result_screen.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(result: state.result),
            ),
          );
        }
        if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.fake,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader().animate().fadeIn(),

                const SizedBox(height: 24),

                // Info Card
                _buildInfoCard().animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 20),

                // Text Input
                _buildTextInput().animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // Action Buttons Row
                _buildActionButtons().animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 24),

                // Analyze Button
                _buildAnalyzeButton().animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 20),

                // Tips Section
                _buildTipsSection().animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analyze News',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Paste or type news content below to detect if it\'s fake or real.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecond,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'ScamShield uses DistilBERT + Bi-LSTM to analyze text patterns and detect misinformation.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: 10,
        minLines: 6,
        decoration: InputDecoration(
          hintText: 'Paste news headline or article text here...\n\nExample:\n"Scientists confirm miracle cure for all diseases discovered overnight"',
          hintStyle: const TextStyle(
            color: AppColors.textSecond,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Character count
        Expanded(
          child: Text(
            '${_textController.text.length} characters',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecond,
            ),
          ),
        ),

        // Paste Button
        OutlinedButton.icon(
          onPressed: _onPaste,
          icon: const Icon(Icons.content_paste, size: 16),
          label: const Text('Paste'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Clear Button
        OutlinedButton.icon(
          onPressed: _textController.text.isEmpty ? null : _onClear,
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecond,
            side: const BorderSide(color: Color(0xFFE0E0E0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return BlocBuilder<ScanCubit, ScanState>(
      builder: (context, state) {
        final isLoading = state is ScanLoading;
        final hasText = _textController.text.trim().length >= 10;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading || !hasText ? null : _onAnalyze,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: isLoading || !hasText ? 0 : 2,
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.document_scanner, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Analyze Text',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips for best results',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildTip(
          icon: Icons.text_fields,
          text: 'Include the full headline and first few paragraphs',
        ),
        _buildTip(
          icon: Icons.translate,
          text: 'Currently supports English text only',
        ),
        _buildTip(
          icon: Icons.wb_sunny_outlined,
          text: 'Minimum 10 characters required for analysis',
        ),
      ],
    );
  }

  Widget _buildTip({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecond),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecond,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _textController.text = data!.text!;
      });
    }
  }

  void _onClear() {
    setState(() {
      _textController.clear();
    });
    context.read<ScanCubit>().reset();
  }

  void _onAnalyze() {
    FocusScope.of(context).unfocus();
    context.read<ScanCubit>().analyzeText(_textController.text);
  }
}