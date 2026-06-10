import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reminder_controller.dart';
import '../models/reminder_model.dart';

class ReminderScreen extends StatelessWidget {
  ReminderScreen({super.key});

  final ReminderController controller = Get.find<ReminderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text(
          '⏰ Reminders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(context),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
        label: const Text(
          'Set Reminder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.reminders.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: controller.reminders.length,
          itemBuilder: (_, index) {
            final reminder = controller.reminders[index];
            return _ReminderCard(
              reminder: reminder,
              onDelete: () => controller.deleteReminder(reminder.id),
              timeUntil: controller.timeUntil(reminder.scheduledAt),
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_off_rounded,
              size: 72,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Reminders Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D44),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap "Set Reminder" to add your first reminder.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddReminderSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(minutes: 5));
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'New Reminder',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D44),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Reminder Title *',
                      prefixIcon: const Icon(Icons.title_rounded,
                          color: Color(0xFF6C63FF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C63FF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Note
                  TextField(
                    controller: noteCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: const Icon(Icons.notes_rounded,
                          color: Color(0xFF6C63FF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C63FF),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Date & Time row
                  Row(
                    children: [
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value:
                              '${selectedDate.day.toString().padLeft(2, '0')}/'
                              '${selectedDate.month.toString().padLeft(2, '0')}/'
                              '${selectedDate.year}',
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                              builder: (ctx, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF6C63FF),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  picked.year,
                                  picked.month,
                                  picked.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerButton(
                          icon: Icons.access_time_rounded,
                          label: 'Time',
                          value:
                              '${selectedTime.hour.toString().padLeft(2, '0')}:'
                              '${selectedTime.minute.toString().padLeft(2, '0')}',
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (ctx, child) => Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF6C63FF),
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                                selectedDate = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  picked.hour,
                                  picked.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Missing Title',
                            'Please enter a reminder title.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red.shade400,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Get.back();
                        controller.addReminder(
                          title: titleCtrl.text,
                          note: noteCtrl.text,
                          scheduledAt: selectedDate,
                        );
                      },
                      child: const Text(
                        'Set Reminder',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─── Reminder Card ────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onDelete;
  final String timeUntil;

  const _ReminderCard({
    required this.reminder,
    required this.onDelete,
    required this.timeUntil,
  });

  @override
  Widget build(BuildContext context) {
    final isFired = reminder.isFired;

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isFired
                  ? const LinearGradient(
                      colors: [Colors.grey, Colors.grey],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF48CAE4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFired ? Icons.alarm_off_rounded : Icons.alarm_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            reminder.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isFired ? Colors.grey : const Color(0xFF2D2D44),
              decoration: isFired ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Text(
                    reminder.note,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(reminder.scheduledAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFired
                      ? Colors.grey.shade200
                      : const Color(0xFF6C63FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeUntil,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isFired ? Colors.grey : const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m $ampm';
  }
}

// ─── Picker Button ─────────────────────────────────────────────────────────────

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.4)),
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF6C63FF).withOpacity(0.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6C63FF)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D44),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
