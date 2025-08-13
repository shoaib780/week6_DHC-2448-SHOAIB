import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:task3/splaishscreen.dart';
import 'firebase_options.dart'; // ✅ ye file flutterfire configure se banti hai
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Web par required
  );

  runApp(DevicePreview(
    enabled: true,
    builder: (context) => MyApp(),
  ));
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Final Task Manager',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // ✅ Recommended with DevicePreview
      locale: DevicePreview.locale(context), // ✅ Optional
      builder: DevicePreview.appBuilder, // ✅ Optional
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFFF6F6F6),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
      ),
      home: splaishscreen(), // ✅ Your custom splash screen
    );
  }
}
