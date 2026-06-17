import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailItineraryPage extends ConsumerWidget {
  final int itineraryId;

  const DetailItineraryPage({
    Key? key,
    required this.itineraryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Details'),
      ),
      body: Center(
        child: Text(
          'Detail Itinerary Page (ID: $itineraryId)',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
