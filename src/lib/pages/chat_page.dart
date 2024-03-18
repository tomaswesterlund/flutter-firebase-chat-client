import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  FirebaseFirestore db = FirebaseFirestore.instance;
  UserService userService = UserService();

  ChatPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  void sendMessage(String message) {
    db.collection('messages').add({
      'text': message,
      'senderId': UserService.userId,
      'timestamp': DateTime.now(),
    });
  } 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
        ),
        body: StreamBuilder(
          stream: db.collection('messages').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading');
            }

            List<Message> messages = snapshot.data!.docs.map((e) {
              return Message.fromJson(e.data());
            }).toList();

            messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      var isMe = userService.isMe(message.senderId);

                      if (isMe) {
                        return BubbleSpecialThree(
                          text: message.text,
                          color: const Color(0xFF1B97F3),
                          tail: false,
                          isSender: true,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        );
                      } else {
                        return  BubbleSpecialThree(
                          text: message.text,
                          color: const Color(0xFFE8E8EE),
                          tail: false,
                          isSender: false,
                        );
                      }
                    },
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Enter your message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(
                            width:
                                10), // Add some spacing between the text field and the button
                        ElevatedButton(
                          onPressed: () {
                            // Validate returns true if the form is valid, otherwise false.
                            if (_formKey.currentState!.validate()) {
                              sendMessage(_textEditingController.text);
                              _textEditingController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // Text color
                          ),
                          child: const Text('Send message'),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );

          },
        ),
      ),
    );
  }
}
