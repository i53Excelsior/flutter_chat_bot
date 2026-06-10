class StructuredResponse {
  final String title;
  final String summary;
  final String category;
  final List<String> keywords;

  StructuredResponse({
    required this.title,
    required this.summary,
    required this.category,
    required this.keywords,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'category': category,
      'keywords': keywords,
    };
  }
}