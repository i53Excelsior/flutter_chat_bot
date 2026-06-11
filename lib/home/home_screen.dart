import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/chat/controllers/json_output_controller.dart';
import '../features/chat/views/chat_screen.dart';
import '../features/chat/views/json_output_screen.dart';
import '../features/reminder/controllers/reminder_controller.dart';
import '../features/reminder/views/reminder_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}) {
    // Register Controllers globally
    Get.put(ReminderController());
    Get.put(JsonOutputController());
  }

  final HomeController homeController = Get.put(HomeController());

  late final List<Widget> _pages = [
    ChatScreen(),
    ReminderScreen(),
    JsonOutputScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: homeController.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: homeController.currentIndex.value,
            onTap: homeController.changeTab,
            backgroundColor: const Color(0xFF12121A),
            selectedItemColor: const Color(0xFF6C63FF),
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  isActive: homeController.currentIndex.value == 0,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.alarm_outlined,
                  activeIcon: Icons.alarm_rounded,
                  isActive: homeController.currentIndex.value == 1,
                ),
                label: 'Reminders',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.code_rounded,
                  activeIcon: Icons.code_rounded,
                  isActive: homeController.currentIndex.value == 2,
                ),
                label: 'JSON',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated bottom nav icon with a pill background when active.
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        isActive ? activeIcon : icon,
        size: 24,
      ),
    );
  }
}
