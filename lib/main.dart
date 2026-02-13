import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/app_provider.dart';
import 'theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await Supabase.initialize(
    url: 'https://argtqpknzqkvwkjremff.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyZ3RxcGtuenFrdndranJlbWZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NzQ1OTgsImV4cCI6MjA4NTU1MDU5OH0.eQzPJvrDJKqVCdLIv501JsYSMS_AELyW2rGh6rtpFqQ',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return MaterialApp(
      title: 'Moujaz',
      debugShowCheckedModeBanner: false,
      themeMode: appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: getLightThemeProvider(appProvider.isModernDesign),
      darkTheme: getDarkThemeProvider(appProvider.isModernDesign),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
