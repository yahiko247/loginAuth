import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String message;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverEmail,
    required this.message
  });

  Map<String, dynamic> mapMessage() {
    return {
      'senderId' : senderId,
      'senderEmail' : senderEmail,
      'receiverId' : receiverId,
      'message' : message,
      'timestamp' : FieldValue.serverTimestamp()
    };
  }
}