import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/app/app.dart';
import 'package:style_house/core/config/supabase_config.dart';

export 'package:style_house/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: StyleHouseApp()));
}
