// ignore_for_file: avoid_print

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget{
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setUpPushNotifications() async{
    final fcm =  FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();//address of device on which app is running
    //can send this token by HTTP req or firestore to backend
    print(token);
    fcm.subscribeToTopic('chat_topic');
  }
  @override
  void initState() {
    super.initState();
    setUpPushNotifications();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('FlutterChat'),
        actions: [ 
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
              //firebase emmits a new event when loffed out,so change in stream, so builder re executed
              //auth token cleared from device
            }, 
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            )
          )
        ],
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages()
          ),
          NewMessage()
        ],
      )
    );
  }
}