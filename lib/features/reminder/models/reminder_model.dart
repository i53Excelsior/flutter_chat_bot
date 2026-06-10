class ReminderModel {
  final String id;
  final String title;
  final String note;
  final DateTime scheduledAt;
  bool isActive;
  bool isFired;

  ReminderModel({
    required this.id,
    required this.title,
    required this.note,
    required this.scheduledAt,
    this.isActive = true,
    this.isFired = false,
  });
}
