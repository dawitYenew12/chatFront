import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/user_list_screen.dart';
import 'providers/auth_provider.dart';
import 'models/message.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(MessageAdapter());
  
  // Open Hive box
  await Hive.openBox<Message>('messages');
  await Hive.openBox('authBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthProvider>(
          builder: (ctx, auth, _) =>
              auth.isAuthenticated ? UserListScreen() : AuthScreen(),
        ),
      ),
    );
  }
}
