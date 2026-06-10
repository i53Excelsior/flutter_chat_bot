import 'package:flutter/material.dart';
import '../models/structured_response.dart';

class StructuredResponseCard extends StatelessWidget {
  final StructuredResponse response;

  const StructuredResponseCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              response.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              response.category,
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 8),

            Text(response.summary),

            const SizedBox(height: 8),

            Wrap(
              spacing: 6,
              children: response.keywords
                  .map(
                    (e) => Chip(
                  label: Text(e),
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}