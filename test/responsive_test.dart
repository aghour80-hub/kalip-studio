import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:style_house/core/utils/responsive_layout.dart';

void main() {
  testWidgets('Responsive Layout Column Calculation Test', (WidgetTester tester) async {
    // Mobile View (width 400)
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Builder(
            builder: (context) {
              expect(ResponsiveLayout.isMobile(context), isTrue);
              expect(ResponsiveLayout.isTablet(context), isFalse);
              expect(ResponsiveLayout.gridColumnCount(context), 2);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    // Tablet View (width 850)
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(850, 1000)),
          child: Builder(
            builder: (context) {
              expect(ResponsiveLayout.isTablet(context), isTrue);
              expect(ResponsiveLayout.gridColumnCount(context), 3);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    // Desktop View (width 1250)
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1250, 1000)),
          child: Builder(
            builder: (context) {
              expect(ResponsiveLayout.isDesktop(context), isTrue);
              expect(ResponsiveLayout.gridColumnCount(context), 4);
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  });
}
