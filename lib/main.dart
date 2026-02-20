import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox('auth');
  await Hive.openBox('missions');
  await Hive.openBox('offline_queue');
  await Hive.openBox('collection_data');
  await Hive.openBox('sync_queue');

  runApp(const ProviderScope(child: LabCollectApp()));
}
