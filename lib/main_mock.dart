import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'mock/mock_auth_provider.dart';
import 'mock/mock_chat_provider.dart';
import 'mock/mock_feed_provider.dart';
import 'mock/mock_group_provider.dart';
import 'mock/mock_user_service.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/group_provider.dart';
import 'providers/user_provider.dart';
import 'utils/app_theme.dart';
import 'utils/theme_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/home/main_shell.dart';

void main() {
  runApp(const FlutterIntraMockApp());
}

class FlutterIntraMockApp extends StatelessWidget {
  const FlutterIntraMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<AppAuthProvider>(
            create: (_) => MockAuthProvider()),
        ChangeNotifierProvider<FeedProvider>(
            create: (_) => MockFeedProvider()),
        ChangeNotifierProvider<GroupProvider>(
            create: (_) => MockGroupProvider()),
        ChangeNotifierProvider<ChatProvider>(
            create: (_) => MockChatProvider()),
        ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider(service: MockUserService())),
      ],
      child: Consumer2<ThemeProvider, AppAuthProvider>(
        builder: (context, themeProv, authProv, _) {
          return MaterialApp(
            title: 'FlutterIntra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProv.mode,
            home: authProv.isLoggedIn
                ? const MainShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

