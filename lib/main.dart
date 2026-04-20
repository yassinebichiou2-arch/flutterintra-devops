import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Listen to Firebase auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await widget.authProv.loadUser(user.uid);
      } else {
        widget.authProv.setUserPublic(null);
      }
      if (mounted) setState(() => _initialized = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.authProv.isLoggedIn
        ? const MainShell()
        : const LoginScreen();
  }
}
