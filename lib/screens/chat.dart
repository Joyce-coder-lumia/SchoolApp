import 'package:flutter/material.dart';
import 'package:edutracker/widgets/database_services_chat.dart';
import 'package:edutracker/widgets/message.dart';
import 'package:intl/intl.dart';
import 'package:edutracker/widgets/chat_input_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edutracker/widgets/app_config.dart';
import 'package:chat_bubbles/chat_bubbles.dart';


class ChatScreen extends StatelessWidget {

  final Message message = Message(
    senderId: "someSenderId",
    recipientId: AppConfig.adminUID,
    text: "Hello, World!",
    timestamp: DateTime.now(),
    type: 'text',
  );
  //Ici je manipule laffichage des dates
  String _displayDate(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (dateToCheck == today) {
      return 'Aujourd\'hui';
    } else if (dateToCheck == yesterday) {
      return 'Hier';
    } else {
      return DateFormat('dd MMMM yyyy').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    DatabaseService dbService = DatabaseService();
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      //backgroundColor: Colors.yellow,
      appBar: AppBar(
        backgroundColor: Color(0xFF336035),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: FutureBuilder<String>(
          future: dbService.getSenderName(message.senderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Row(
                children: [
                  CircleAvatar(), // Configurez votre avatar ici
                  SizedBox(width: 8),
                  Text(snapshot.data!),
                ],
              );
            } else {
              return Text("Chargement...");
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              // Ajoutez ici le code pour afficher le menu de navigation
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          StreamBuilder<List<Message>>(
            // Utilisation de getChatMessages pour écouter les messages en temps réel
            stream: dbService.getMessages(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Erreur lors du chargement des messages.');
              }
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data!;
              return Padding(
                padding: EdgeInsets.only(bottom: 80.0),
                child: ListView.builder(
                  reverse: true,
                  // Pour que les messages les plus récents apparaissent en bas
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isParent = message.senderId == currentUser?.uid;
                    TextAlign textAlign = isParent ? TextAlign.right : TextAlign.left;

                    bool shouldDisplayDate = index == 0 ||
                        _displayDate(messages[index - 1].timestamp) != _displayDate(message.timestamp);

                    return Column(
                      crossAxisAlignment: isParent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (shouldDisplayDate)
                            Align(
                              alignment: Alignment.center, // Centre le conteneur
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade900,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                margin: EdgeInsets.only(bottom: 8, top: 8),
                                child: Text(
                                  _displayDate(message.timestamp),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),),




                        BubbleSpecialThree(
                          text: message.text,
                          isSender: isParent,
                          color: isParent ? Colors.deepOrange.shade200 : Colors.black54,
                          tail: true,
                          textStyle: TextStyle(
                            color: isParent ? Colors.white : Colors.white,
                            fontSize: 16
                          ),
                           sent: true,
                           seen: true,
                           delivered: true,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 4.0,
                            right: isParent ? 16.0 : 0,
                            left: !isParent ? 16.0 : 0,
                          ),
                          child: Text(
                            DateFormat('HH:mm').format(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),

                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 16.0,
            left: 40.0,
            right: 40.0,
            child: ChatInputWidget(),
          ),
        ],
      ),
    );
  }
}
