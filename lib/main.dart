import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open boxes for user progress and vocabulary cache
  await Hive.openBox('user_progress');
  await Hive.openBox('vocabulary_cache');

  runApp(
    const ProviderScope(
      child: DeutschBlitzApp(),
    ),
  );
}
