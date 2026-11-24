import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/localization/language_provider.dart';
import 'package:style_house/core/router/app_router.dart';
import 'package:style_house/core/theme/app_theme.dart';

/// The root application widget for KALIP studio.
///
/// Configures Riverpod state listeners for dynamic language switching,
/// luxury Material 3 design system, and GoRouter declarative navigation.
class StyleHouseApp extends ConsumerWidget {
  const StyleHouseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final isKhmer = ref.watch(localizationProvider).isKhmer;

    return MaterialApp.router(
      title: 'KALIP studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(isKhmer: isKhmer),
      routerConfig: router,
    );
  }
}
