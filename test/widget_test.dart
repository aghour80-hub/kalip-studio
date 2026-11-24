import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:style_house/main.dart';

void main() {
  testWidgets('KALIP studio App smoke and navigation test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: StyleHouseApp()));

    // Pump a few frames to let initial layout render
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify brand name is present
    expect(find.text('KALIP studio'), findsWidgets);

    // Verify bottom navigation bar items
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Wishlist'), findsWidgets);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    // Tap Categories
    await tester.tap(find.text('Categories'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Explore Collections'), findsOneWidget);

    // Tap Wishlist
    await tester.tap(find.text('Wishlist'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('My Wishlist'), findsOneWidget);

    // Tap Orders
    await tester.tap(find.text('Orders'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('My Orders'), findsOneWidget);

    // Tap Profile
    await tester.tap(find.text('Profile'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Account & Settings'), findsOneWidget);
  });
}
