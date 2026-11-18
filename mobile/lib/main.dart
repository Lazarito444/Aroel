import 'package:aroel/app/app.dart';
import 'package:aroel/app/bootstrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod/misc.dart' show Override;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final List<Override> overrides = await bootstrapAroel();

  runApp(ProviderScope(overrides: overrides, child: const AroelApp()));
}
