import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scamshield_app/cubits/auth/auth_cubit.dart';
import 'package:scamshield_app/cubits/auth/auth_state.dart';
import 'package:scamshield_app/utils/app_colors.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.fake,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 45,
                        color: Colors.white,
                      ),
                    ),
                  ).animate().fadeIn().scale(),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const Center(
                    child: Text(
                      'Sign In to continue',
                      style:TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecond,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')){
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outlined,
                    ).copyWith(
                      suffixIcon: IconButton(icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecond,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty){
                        return 'Please enter your password';
                      }
                      if (value.length < 6){
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      );
                    },
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: AppColors.textSecond),
                        ),
                        GestureDetector(
                          onTap: ()=> Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
          ),
      ),
      );
  }

  void _onLogin(){
    if(_formKey.currentState!.validate()){
      context.read<AuthCubit>().login(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textSecond),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}