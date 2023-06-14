// ignore_for_file: avoid_print

import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget{
  const ChatMessages({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore
        .instance
        .collection('chat')
        .orderBy('createdAt',descending: true)
        .snapshots(),
      //snapshots yield such a stream and basically listens to changes on 'chats'
      //and execute builder function when there is change
       builder: (context, snapshot) {
         if(snapshot.connectionState == ConnectionState.waiting){
          return  const Center(
            child: CircularProgressIndicator()
          );
         }
         if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
          if(!snapshot.hasData){
            print('snapshot has no data');
          }
          else{
            print('docs is empty');
          }
          return  const Center(
            child: Text('No messages found..')
          );
         }
         if(snapshot.hasError){
          return  const Center(
            child: Text('Something went wrong..')
          );
         }
         final loadedMessages = snapshot.data!.docs;
         return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40,left: 30,right: 30),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = 
              index+1 < loadedMessages.length ? loadedMessages[index+1].data() : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextChatMessageUserId = 
              nextChatMessage != null ? nextChatMessage['userId'] : null;
            bool nextUserIsSame = nextChatMessageUserId == currentMessageUserId;
            if(nextUserIsSame){
              return MessageBubble.next(
                message: chatMessage['text'], 
                isMe: authenticatedUser.uid == currentMessageUserId
              );
            }
            else{
              return MessageBubble.first(
                userImage: chatMessage['userImage'], 
                username: chatMessage['username'], 
                message: chatMessage['text'], 
                isMe: authenticatedUser.uid == currentMessageUserId
              );
            }

          },
        );
       },
    );
  }
}