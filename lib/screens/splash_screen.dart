import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/model_service.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final ModelService modelService;

  const SplashScreen({
    super.key,
    required this.modelService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
  setState(() => _loadingText = 'Loading AI model...');

  final start = DateTime.now();

  while (!widget.modelService.isLoaded) {
    await Future.delayed(const Duration(milliseconds: 200));

    // 🔥 timeout after 10 seconds
    if (DateTime.now().difference(start).inSeconds > 10) {
      debugPrint("⚠️ Model load timeout — continuing anyway");
      break;
    }
  }

  setState(() => _loadingText = 'Ready!');
  await Future.delayed(const Duration(milliseconds: 500));

  if (!mounted) return;
  _navigateNext();
}

  void _navigateNext() {
    final authState = context.read<AuthCubit>().state;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => authState is AuthAuthenticated
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield,
                  size: 60,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'ScamShield',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'DistilBERT + Bi-LSTM',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueAccent,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 48),

              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Shows live loading status
              Text(
                _loadingText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}