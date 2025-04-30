import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'package:to_do/views/screens/home_screen.dart';
import 'package:to_do/views/screens/shared_task_detail.dart';
import 'providers/task_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<Uri?> _linkSub;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    // Listen for both the very first deep link and any that occur while the app is running
    _linkSub = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) => debugPrint('Deep link error: $err'),
    );
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;
    // expecting todoapp://task/<taskId>
    if (uri.scheme == 'todoapp' && uri.host == 'task') {
      final taskId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      if (taskId != null) {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => SharedTaskDetailScreen(taskId: taskId),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'To-Do App',
        navigatorKey: _navigatorKey,
        home: const HomeScreen(),
      ),
    );
  }
}
