import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scamshield_app/cubits/auth/auth_cubit.dart';
import 'package:scamshield_app/cubits/auth/auth_state.dart';
import 'package:scamshield_app/utils/app_colors.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final authState = context.read<AuthCubit>().state;
    if(authState is AuthAuthenticated) {
      _goTo(const HomeScreen());
    } else {
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security,
                size: 60,
                color: Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5)),

          const SizedBox(height: 24),

          const Text(
            'ScamShield',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          )

          .animate()
          .fadeIn(delay: 300.ms, duration: 600.ms)
          .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 8),

        const Text(
          'Protecting You From Fake News',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        )

         .animate()
         .fadeIn(delay: 500.ms, duration: 600.ms),
        const SizedBox(height: 60),

        const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        )
            .animate()
            .fadeIn(delay: 800.ms),
        
        const SizedBox(height: 40),

        const Text(
          'Powered by DistilBERT + Bi-LSTM',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white54,
          ),
        )
          .animate()
          .fadeIn(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
}