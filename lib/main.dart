import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'utils/seed_data.dart';
import 'providers/chat_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/group_provider.dart';
import 'providers/user_provider.dart';
import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ignore: avoid_print
  print('✅ Firebase connecté au projet: ${Firebase.app().options.projectId}');
  await NotificationService.init();
  // Uncomment line below ONCE to create test accounts, then comment it back
  await seedTestData();
  runApp(const FlutterIntraApp());
}

class FlutterIntraApp extends StatelessWidget {
  const FlutterIntraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer2<ThemeProvider, AppAuthProvider>(
        builder: (context, themeProv, authProv, _) {
          return MaterialApp(
            title: 'FlutterIntra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProv.mode,
            home: _AuthGate(authProv: authProv),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  final AppAuthProvider authProv;
  const _AuthGate({required this.authProv});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        widget.authProv.loadUser(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.authProv.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.authProv.isLoggedIn
        ? const MainShell()
        : const LoginScreen();
  }
}




