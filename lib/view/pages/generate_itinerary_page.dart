import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GenerateItineraryPage extends ConsumerWidget {
  const GenerateItineraryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Itinerary'),
      ),
      body: Center(
        child: Text(
          'Generate Itinerary Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
