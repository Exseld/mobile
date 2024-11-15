import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestion_classe/pages/auth_screen.dart';
import 'package:gestion_classe/pages/calendrier_screen.dart';

import 'firebase_options.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // Nous attendons l'initialisation
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        // Houston!!?
        if (snapshot.hasError) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: const Center(
              child: Text("PROBLEME!!!"),
            ),
          );
        }

        // L'application peut démarrer
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 255, 60, 176),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {

                // Si le stream a des données, nous avons une session
                // if (snapshot.hasData) return const ChatScreen();
                if (snapshot.hasData) return const Placeholder();//CalendarScreen();

                // Sinon pas de session valide
                return const AuthScreen();
              },
            )
        );
      },
    );
  }
}