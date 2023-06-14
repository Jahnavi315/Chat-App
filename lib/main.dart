// ignore_for_file: avoid_print

import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 45, 111, 161)),
            //const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {//when new stream builder executes,can get access to stream by snapshot
          print('builder executing....${snapshot.connectionState}');
          if(snapshot.connectionState == ConnectionState.waiting){
            return const SplashScreen();
          }
          if(snapshot.hasData){//user logged in
            print('ready to show CHAT');
            //print(snapshot.data);
            return const ChatScreen();
          }
          print('ready to show AUTH');
          return const AuthScreen();
        },
      )
    );
  }
}