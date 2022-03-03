import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:osmanbaba/Models/Message.dart';
import 'package:signalr_client/http_connection_options.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/hub_connection_builder.dart';
import 'package:http/http.dart' as http;

class SignalRHelper {
  final url = 'https://OsmanBaba.appinfinitytouch.net/chathub';
  HubConnection hubConnection;
  var messageList = <Message>[];
  String textMessage = '';

  Future<String> getAccessToken() async {
    return await "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJOYW1lIjoiTk9PUiIsIlJvbGUiOiJDb21wYW55IiwiZXhwIjoxNjM3NjU2OTQ5LCJpc3MiOiJJbnZlbnRvcnlBdXRoZW50aWNhdGlvblNlcnZlciIsImF1ZCI6IkludmVudG9yeVNlcnZpY2VQb3RtYW5DbGllbnQifQ.aBQbDtJzNt87zPlbo-6p8zOzpxD5KUYiY5Ag9uQVR2g";
  }

  void connect(receiveMessageHandler) async {
    print('sssssssssssssssssssss');
    hubConnection = HubConnectionBuilder().withUrl(url,
        options: HttpConnectionOptions(accessTokenFactory: () async {
      return await getAccessToken();
    })).build();
    hubConnection.onclose((error) {
      log('Connection Close');
    });
    hubConnection.on('ReceiveMessage', receiveMessageHandler);
    await hubConnection.start();
    print('cccccccc');
    print(hubConnection.state);
  }

  void sendMessage(String name, String message) async {
    print('dddddddddddddd');
    var head = {
      "Accept": "application/json",
      "content-type": "application/json"
    };
    var response = await http.post(
        Uri.parse("https://OsmanBaba.appinfinitytouch.net/api/AddMessage"),
        body: jsonEncode({
          'message': message,
          'receiver': "OsmanBaba",
          'sender': 'NOOR',
          'user': 'NOOR'
        }),
        headers: head);

    print(response.statusCode);

    hubConnection.invoke('SendMessage', args: [name, message]);
    //  messageList.add(Message(name: name, message: message, isMine: true));
    textMessage = '';
  }

  void disconnect() {
    hubConnection.stop();
  }
}
