// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wealthwise/main.dart';



void main() {
  testWidgets('SplashSScreen navigates to home', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WealthWiseApp());



    //wait for all animations/timersto complete
    await tester.pumpAndSettle;



  //check if home screen contains the welcome text
   expect(find.text('Welcome to WealthWise!'), findsOneWidget);
  });
}
