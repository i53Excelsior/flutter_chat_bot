import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/chat/views/chat_screen.dart';
import '../features/reminder/controllers/reminder_controller.dart';
import '../features/reminder/views/reminder_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}) {
    // Register ReminderController globally once here
    Get.put(ReminderController());
  }

  final RxInt _currentIndex = 0.obs;

  late final List<Widget> _pages = [
    ChatScreen(),
    ReminderScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: _currentIndex.value,
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
            currentIndex: _currentIndex.value,
            onTap: (i) => _currentIndex.value = i,
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
                  isActive: _currentIndex.value == 0,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: _NavIcon(
                  icon: Icons.alarm_outlined,
                  activeIcon: Icons.alarm_rounded,
                  isActive: _currentIndex.value == 1,
                ),
                label: 'Reminders',
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
