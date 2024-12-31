import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:booksnap/main.dart'; // Update with your actual project path

void main() {
  testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Removed const

    // Verify that the splash screen shows up
    expect(find.text('BOOKSNAP'), findsOneWidget);
  });

  testWidgets('LoginScreen navigates to DataPage', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // Removed const

    // Fill in PRN and password fields
    await tester.enterText(find.byType(TextField).first, '12345'); // Example PRN
    await tester.enterText(find.byType(TextField).last, 'password123'); // Example password
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify that the DataPage is displayed
    expect(find.text('Welcome, 12345!'), findsOneWidget);
  });

  testWidgets('DataPage shows return date after submitting', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp()); // Removed const

    // Navigate to LoginScreen
    await tester.enterText(find.byType(TextField).first, '12345');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Navigate to DataPage
    expect(find.text('Welcome, 12345!'), findsOneWidget);

    // Fill in the issue date and notification time
    await tester.enterText(find.byType(TextField).first, '15-09-23'); // Example date
    await tester.enterText(find.byType(TextField).at(1), '10:00'); // Example time
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify return date message appears
    expect(find.text('Your Return Date is:'), findsOneWidget);
  });
}
