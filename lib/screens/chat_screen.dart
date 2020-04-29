import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final _firestore=Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {

  static String id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth=FirebaseAuth.instance;
  
  String messageText;

  //to erase text in input field after send
  final messageTextController=  TextEditingController();

  @override
  void initState() {
    
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
    final user=await _auth.currentUser();
    try{
      if(user!=null){
      loggedInUser=user;
      print(loggedInUser.email);
    }
    }catch(e){
      print(e);
    }
  }
  //for getting database
  //realtime stream
  void getMessagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()){
        for(var message in snapshot.documents){
          print(message.data);
        }
    }
    //getting all documents
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      //to clear the input text
                      controller:messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //to clear the text in input
                      messageTextController.clear();
                      //Implement send functionality.
                      //sender is logged in user
                      //updating data
                      _firestore.collection('messages').add({
                        //map object
                        'text':messageText,
                        'sender':loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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
  @override
  Widget build(BuildContext context) {
    return //streambuilder build widget whenever streamupdates
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              //builder rebuilds the widgets
              //below snaphot is different from firebase 
              //it is flutter snapshot
              builder:(context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child:CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages=snapshot.data.documents;
                List<MessageBubble> messageBubbles=[];
                //message is document snapshot from firebase
                //but upper snapshot is of flutter
                //for creating widget
                for(var message in messages){
                  final messageText=message.data['text'];
                  final messageSender=message.data['sender'];

                  //to differentiate bw users
                  final currentUser=loggedInUser.email;
                    
                  final messageBubble=MessageBubble(
                    sender:messageSender,
                    text: messageText,
                    isMe:currentUser==messageSender,
                  );
                  messageBubbles.add(messageBubble);
                }
                //return built widgets
                //as list view for scrolling 
                return Expanded(
                  child: ListView(
                    //to show newest mssage first at bottom
                    reverse:true,
                    padding:EdgeInsets.symmetric(horizontal:10.0,vertical:20.0),
                    children: messageBubbles,
                  ),
                ); 
              } 
            );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender,this.text,this.isMe});

  final String sender;
  final String text;
  final bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:isMe? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style:TextStyle(
              fontSize: 12.0,
              color:Colors.black54,
            )
          ),
          Material(
            borderRadius:isMe? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ):BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ),
            elevation: 5.0,
            color:isMe?Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(
                text,
                style:TextStyle(
                  color:isMe?Colors.white:Colors.black54,
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