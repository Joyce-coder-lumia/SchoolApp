import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutracker/screens/chat.dart';
import 'package:edutracker/widgets/message.dart';

class DatabaseService{
  Future<String> getSenderName(String senderId) async {
    var sender = await FirebaseFirestore.instance.collection('admins').doc(senderId).get();
    return sender.data()?['name'] ?? 'Inconnu';
  }

  Stream<List<Message>> getMessages() {
    return FirebaseFirestore.instance
        .collection('messages') // Assurez-vous que 'messages' est le nom correct de votre collection
        .orderBy('timestamp', descending: true) // Pour obtenir les messages les plus récents en premier
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }


}