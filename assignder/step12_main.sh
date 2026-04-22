#!/bin/bash

# ============================================
#   Assignder - Step 12: main.dart
#   bash step12_main.sh
# ============================================

set -e

echo "📝 Writing main.dart..."

cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/assignment_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(const AssignderApp());
}

class AssignderApp extends StatelessWidget {
  const AssignderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter(context);
          return MaterialApp.router(
            title: 'Assignder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
EOF

echo "✅ main.dart written!"
echo ""
echo "============================================"
echo "  ✅ Step 12 Complete — main.dart"
echo "  👉 Run: flutter analyze"
echo "  👉 Then run: flutter run"
echo "============================================"
