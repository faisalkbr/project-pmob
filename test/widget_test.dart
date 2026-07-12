import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sesuaikan path import ini jika ada yang berbeda
import 'package:markup_mobile/app.dart';
import 'package:markup_mobile/viewmodels/auth_viewmodel.dart';
import 'package:markup_mobile/viewmodels/dashboard_viewmodel.dart';

void main() {
  testWidgets('App should render without crashing', (WidgetTester tester) async {
    // 1. Build aplikasi kita dengan MultiProvider yang sama persis dengan main.dart
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
          ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ],
        child: const MarkUpApp(),
      ),
    );

    // 2. Tunggu sebentar untuk memastikan widget selesai dimuat
    await tester.pumpAndSettle();

    // 3. Verifikasi sederhana: Pastikan ada MaterialApp yang berhasil di-render
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}