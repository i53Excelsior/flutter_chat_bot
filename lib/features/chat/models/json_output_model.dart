class JsonOutputModel {
  final String id;
  final String title;
  final dynamic data; // Map<String, dynamic> or List<dynamic>
  final DateTime createdAt;

  JsonOutputModel({
    required this.id,
    required this.title,
    required this.data,
    required this.createdAt,
  });
}
