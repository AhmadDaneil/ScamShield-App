import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/navigation/navigation_cubit.dart';
import '../cubits/navigation/navigation_state.dart';
import '../utils/app_colors.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Widget> _pages = [
    const AnalyzeScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, navState){
        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.security,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'ScamShield',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          body: _pages[navState.currentIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: navState.currentIndex,
            onDestinationSelected: (index) =>
                context.read<NavigationCubit>().changePage(index),
            destinations: const[
              NavigationDestination(
                icon: Icon(Icons.document_scanner_outlined),
                selectedIcon: Icon(Icons.document_scanner),
                label: 'Analyze',
                ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined),
                selectedIcon: Icon(Icons.history),
                label: 'History',
                ),
            ],
            ),
        );
      },
    );
  }
}