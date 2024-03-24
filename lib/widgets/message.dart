import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String recipientId;
  String text;
  DateTime timestamp;
  String? type;

  Message({required this.senderId,required this.recipientId, required this.text, required this.timestamp, this.type});

  // Factory constructor pour créer une instance de ChatMessage à partir d'un document Firestore
  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Message(
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      text: data['text'] ?? '', // Assurez-vous que vos documents Firestore ont un champ 'text'
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'],
    );
  }
}