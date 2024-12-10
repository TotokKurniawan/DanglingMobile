import 'package:damping/GradientBackground.dart';
import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  static String routename = '/message';

  const Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0), // Tinggi AppBar
        child: AppBar(
          title: const Text('Pesan'), // Menambahkan judul untuk AppBar
          automaticallyImplyLeading: false, // Menonaktifkan tombol back
        ),
      ),
      body: GradientBackground(
        // Menggunakan GradientBackground
        child:
            ChatListScreen(), // Tampilkan ChatListScreen sebagai konten utama
      ),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  static String routeName = "/chatList";

  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final List<Map<String, String>> _chats = [
    {
      'name': 'metwireofficial',
      'message': 'Itu kak',
      'date': '16/07',
      'status': 'Dibatasi',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'zebrakencana',
      'message': 'Halo Kak, kami sungguh...',
      'date': '15/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'chatbot123',
      'message': 'Apakah ada yang bisa saya bantu?',
      'date': '14/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'user007',
      'message': 'Kapan kita bisa bertemu?',
      'date': '13/06',
      'status': 'Dibatasi',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'janedoe',
      'message': 'Saya telah mengirimkan dokumen.',
      'date': '12/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'johnsmith',
      'message': 'Tolong kirimkan saya tautan.',
      'date': '11/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'mikejones',
      'message': 'Saya setuju dengan pendapat Anda.',
      'date': '10/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'susanlee',
      'message': 'Ada pembaruan tentang proyek?',
      'date': '09/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'emilyclark',
      'message': 'Jangan lupa pertemuan hari ini!',
      'date': '08/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'robertbrown',
      'message': 'Terima kasih atas bantuanmu!',
      'date': '07/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'alexjohnson',
      'message': 'Ada kabar terbaru?',
      'date': '06/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'katherine',
      'message': 'Saya baru saja menyelesaikan tugas.',
      'date': '05/06',
      'status': 'Dibatasi',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'peterparker',
      'message': 'Ada yang bisa saya bantu?',
      'date': '04/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'tonystark',
      'message': 'Saya memiliki ide baru untuk proyek ini.',
      'date': '03/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'stevejobs',
      'message': 'Apakah kita masih bertemu nanti?',
      'date': '02/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'michaeljackson',
      'message': 'Jangan lewatkan acara besok!',
      'date': '01/06',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'willsmith',
      'message': 'Saya senang bisa bekerja dengan Anda.',
      'date': '31/05',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'leonardodicaprio',
      'message': 'Film yang bagus!',
      'date': '30/05',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'oprahwinfrey',
      'message': 'Inspirasi yang luar biasa!',
      'date': '29/05',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'serenawilliams',
      'message': 'Sangat senang bisa berkolaborasi.',
      'date': '28/05',
      'avatar': 'https://via.placeholder.com/50',
    },
    {
      'name': 'beyonce',
      'message': 'Apakah kamu sudah mendengarnya?',
      'date': '27/05',
      'avatar': 'https://via.placeholder.com/50',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _chats.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(_chats[index]['avatar']!),
                    ),
                    title: Text(_chats[index]['name']!),
                    subtitle: Text(_chats[index]['message']!),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_chats[index]['date']!),
                        if (_chats[index]['status'] != null)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _chats[index]['status']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageScreen(
                            chatName: _chats[index]['name']!,
                            avatarUrl: _chats[index]['avatar']!,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(), // Menambahkan garis pemisah
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// Pastikan untuk mengimpor atau mendefinisikan MessageScreen di tempat lain
class MessageScreen extends StatelessWidget {
  final String chatName;
  final String avatarUrl;

  const MessageScreen(
      {Key? key, required this.chatName, required this.avatarUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
      ),
      body: Center(
        child: Text('Chat with $chatName'),
      ),
    );
  }
}
