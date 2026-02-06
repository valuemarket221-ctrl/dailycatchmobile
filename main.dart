import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/src/features/authentication/presentation/auth_wrapper.dart';

// Firebase options are now handled in the Dart code for reliability.
const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyCr9RvlsDfDchsTbafxH7EsELC1G_hY31c",
  authDomain: "dailycatchapp-2250781-da029.firebaseapp.com",
  projectId: "dailycatchapp-2250781-da029",
  storageBucket: "dailycatchapp-2250781-da029.appspot.com", // Corrected storage bucket domain
  messagingSenderId: "476454942774",
  appId: "1:476454942774:web:7e1b8a35ca1b8794024097",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with the options specified above.
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dailycatch.app',
      theme: ThemeData(
        primaryColor: AppColors.blueBic,
        colorScheme: ColorScheme(
          primary: AppColors.blueBic,
          secondary: AppColors.yellowColor,
          surface: Colors.white,
          error: const Color.fromARGB(255, 253, 27, 11),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          color: AppColors.blueBic,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: AppColors.yellowColor,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), 
    );
  }
}
