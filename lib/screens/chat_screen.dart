import 'package:flutter/material.dart';
import 'package:flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firestore = FirebaseFirestore.instance;
late User LoggedInUser ;
class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
   late String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void  getCurrentUser()async{
     try{
       final user = await _auth.currentUser;
       if(user !=null)
       {
         LoggedInUser = user;
         print(LoggedInUser.email);
       }
     }catch(e){
          print(e);
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                   _auth.signOut();
                   Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            const MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: ()async{
                      messageTextController.clear();
                        await _firestore.collection('message').add({

                           'text': messageText,
                           'sender': LoggedInUser.email,
                          });
                  },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('message').snapshots(),
        builder: (context , snapshot){
          if(snapshot.hasData)
          {
            final messages = snapshot.data?.docs??[].reversed;
            List<MessageBubble> messageBubbles = [];
            messages.forEach((message) {
              final messageText = message['text'];
              final messageSender = message['sender'];

              final currentUser = LoggedInUser.email;

              final messageBubble = MessageBubble(sender: messageSender, text: messageText , isMe: currentUser==messageSender,);
              messageBubbles.add(messageBubble);
            });
            return Expanded(
              child: ListView(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical : 20.0 ),
                children: messageBubbles,
              ),
            );
          }
          else
          {
            return const Text(' ');
          }
        }
    );
  }
}



class MessageBubble extends StatelessWidget {
 MessageBubble({required this.sender,required this.text ,required this.isMe});

  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[
          Text( sender,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12.0
          ),
          ),
          Material(
            borderRadius: isMe? const BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft:Radius.circular(30.0),
                bottomRight:Radius.circular(30.0) ): const BorderRadius.only(topRight: Radius.circular(30.0),bottomRight:Radius.circular(30.0),
                bottomLeft:Radius.circular(30.0) ),
            elevation: 5.0,
            color: isMe?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(text,
                style: TextStyle(
                  color: isMe?Colors.white:Colors.black54 ,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

