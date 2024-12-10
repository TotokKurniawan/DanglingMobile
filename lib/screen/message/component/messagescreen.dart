import 'dart:io'; // Import untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Untuk format waktu

class MessageScreen extends StatefulWidget {
  final String chatName;
  final String avatarUrl;

  const MessageScreen({
    Key? key,
    required this.chatName,
    required this.avatarUrl,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = []; // Menyimpan pesan dan gambar

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        // Menambahkan gambar ke pesan
        _messages.add({'image': File(pickedFile.path)});
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        // Menambahkan pesan teks ke daftar pesan
        _messages.add({
          'text': _messageController.text,
          'time':
              DateFormat('HH:mm').format(DateTime.now()), // Menambahkan waktu
        });
        _messageController.clear();
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showFullImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageScreen(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 10),
            Text(widget.chatName),
          ],
        ),
        backgroundColor: Colors.indigoAccent, // Menggunakan tema warna
        elevation: 4, // Tambahkan efek bayangan
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
      body: SafeArea(
        // Menambahkan SafeArea di sini
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.indigoAccent.withOpacity(
                              0.1), // Menggunakan tema warna untuk pesan
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (message['text'] != null) ...[
                              Text(
                                message['text'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                            ],
                            if (message['image'] != null) ...[
                              GestureDetector(
                                onTap: () => _showFullImage(message['image']),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    message['image'],
                                    width: 200, // Lebar gambar
                                    height: 200, // Tinggi gambar
                                    fit: BoxFit
                                        .cover, // Mengatur agar gambar memenuhi kontainer
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                            ],
                            Text(
                              message['time'] ??
                                  '14:58', // Menampilkan waktu yang dinamis
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent
                            .withOpacity(0.1), // Warna latar belakang
                        borderRadius: BorderRadius.circular(30), // Sudut bulat
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          border: InputBorder.none, // Menghilangkan border
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20), // Padding dalam
                          prefixIcon: const Icon(Icons.message,
                              color: Colors.indigoAccent), // Ikon pesan
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.indigoAccent),
                    onPressed: _sendMessage,
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

class FullImageScreen extends StatelessWidget {
  final File image;

  const FullImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
        backgroundColor: Colors.indigoAccent, // Menggunakan tema warna
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Image.file(image),
      ),
    );
  }
}
