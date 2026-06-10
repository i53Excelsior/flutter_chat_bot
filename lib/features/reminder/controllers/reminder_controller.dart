import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/reminder_model.dart';

class ReminderController extends GetxController {
  final RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final Map<String, Timer> _timers = {};

  /// Add a new reminder and schedule its timer.
  void addReminder({
    required String title,
    required String note,
    required DateTime scheduledAt,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final reminder = ReminderModel(
      id: id,
      title: title.trim(),
      note: note.trim(),
      scheduledAt: scheduledAt,
    );
    reminders.add(reminder);
    _scheduleTimer(reminder);
    Get.snackbar(
      '✅ Reminder Set',
      '"${reminder.title}" scheduled for ${_formatDateTime(scheduledAt)}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.alarm_on, color: Colors.white),
    );
  }

  void _scheduleTimer(ReminderModel reminder) {
    final duration = reminder.scheduledAt.difference(DateTime.now());
    if (duration.inSeconds < 1) {
      _fireReminder(reminder);
      return;
    }
    final timer = Timer(duration, () => _fireReminder(reminder));
    _timers[reminder.id] = timer;
  }

  void _fireReminder(ReminderModel reminder) {
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index].isFired = true;
      reminders[index].isActive = false;
      reminders.refresh();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm, color: Colors.white, size: 56),
              const SizedBox(height: 16),
              Text(
                reminder.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (reminder.note.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  reminder.note,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 12,
                  ),
                ),
                onPressed: Get.back,
                child: const Text(
                  'Dismiss',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void deleteReminder(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
    reminders.removeWhere((r) => r.id == id);
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $h:$m $ampm';
  }

  String timeUntil(DateTime scheduledAt) {
    final diff = scheduledAt.difference(DateTime.now());
    if (diff.isNegative) return 'Fired';
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h left';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m left';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m left';
    return '${diff.inSeconds}s left';
  }

  @override
  void onClose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    super.onClose();
  }
}
