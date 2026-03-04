import 'dart:async';
import 'dart:convert';
import 'package:damping/core/widgets/GradientBackground.dart';
import 'package:flutter/material.dart';
import 'package:damping/features/chats/services/chat_service.dart';
import 'package:damping/core/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ────────────────────────────────────────────────────────────────
//  Daftar Percakapan
// ────────────────────────────────────────────────────────────────
class Message extends StatelessWidget {
  static String routename = '/message';

  const Message({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
          title: const Text('Pesan'),
          automaticallyImplyLeading: false,
        ),
      ),
      body: GradientBackground(child: const ChatListScreen()),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  static String routeName = '/chatList';
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    final data = await _chatService.getConversations();
    setState(() {
      _conversations = data ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_conversations.isEmpty) {
      return const Center(
          child: Text('Belum ada percakapan.',
              style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Cari percakapan',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _conversations.length,
            itemBuilder: (context, index) {
              final c = _conversations[index];
              final conversationId = c['id'];
              final partnerName = c['partner_name'] ?? 'Pengguna';
              final partnerPhoto = c['partner_photo'];
              final unreadCount = c['unread_count'] ?? 0;
              final latestMsg = c['latest_message'];
              final latestText =
                  latestMsg != null ? latestMsg['message'] : 'Mulai percakapan';

              return Column(children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent,
                    backgroundImage:
                        partnerPhoto != null ? NetworkImage(partnerPhoto) : null,
                    child: partnerPhoto == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  title: Text(partnerName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    latestText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0 ? Colors.black : Colors.grey.shade600,
                      fontWeight:
                          unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: Text(unreadCount.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                        )
                      : const SizedBox.shrink(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MessageScreen(
                        conversationId: conversationId,
                        chatName: partnerName,
                        avatarUrl: partnerPhoto,
                      ),
                    ),
                  ).then((_) => _fetchConversations()),
                ),
                const Divider(height: 1),
              ]);
            },
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
//  Layar Chat dengan WebSocket Real-time (Laravel Reverb)
// ────────────────────────────────────────────────────────────────
class MessageScreen extends StatefulWidget {
  final int conversationId;
  final String chatName;
  final String? avatarUrl;

  const MessageScreen({
    Key? key,
    required this.conversationId,
    required this.chatName,
    this.avatarUrl,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _messages = [];
  bool _isLoading = true;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── HTTP: ambil history pesan ──────────────────────────────────
  Future<void> _fetchMessages() async {
    final messages = await _chatService.getMessages(widget.conversationId);
    if (mounted) {
      setState(() {
        _messages = messages ?? [];
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // ── WebSocket: subscribe ke private channel Reverb ─────────────
  Future<void> _connectWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      // Reverb menggunakan protokol Pusher-compatible
      // ws://{host}:{port}/app/{key}
      final wsUri = Uri.parse(ApiEndpoints.reverbWsUrl);
      _channel = WebSocketChannel.connect(wsUri);

      // 1. Subscribe ke private channel setelah connected
      //    Reverb/Pusher protocol: kirim event "subscribe"
      final subscribePayload = jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': 'private-conversation.${widget.conversationId}',
          'auth': '', // Reverb handles auth via /broadcasting/auth endpoint
        },
      });

      _channel!.sink.add(subscribePayload);

      // 2. Dengarkan pesan masuk
      _wsSubscription = _channel!.stream.listen(
        (rawData) {
          final decoded = jsonDecode(rawData as String);
          final event = decoded['event'] as String?;

          if (event == 'message.sent' || event == 'App\\Events\\MessageSent') {
            final data = jsonDecode(decoded['data'] as String);

            // Hanya tambahkan pesan dari lawan bicara (pesan sendiri sudah ditambahkan secara optimistik)
            if (data['is_mine'] != true) {
              if (mounted) {
                setState(() {
                  _messages.add({
                    'id': data['id'],
                    'message': data['message'],
                    'is_mine': false,
                    'is_read': data['is_read'],
                    'created_at': data['created_at'],
                  });
                });
                _scrollToBottom();
              }
            }
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          // Reconnect setelah 3 detik
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
        onDone: () {
          debugPrint('WebSocket disconnected. Reconnecting...');
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
      );
    } catch (e) {
      debugPrint('WebSocket connect failed: $e');
    }
  }

  // ── Kirim pesan ──────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    // Tambahkan secara optimistik (langsung tampil tanpa menunggu server)
    setState(() {
      _messages.add({
        'message': text,
        'is_mine': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    final success = await _chatService.sendMessage(widget.conversationId, text);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan')));
      _fetchMessages(); // rollback pada kegagalan
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.indigoAccent,
            backgroundImage:
                widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
            child: widget.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(widget.chatName,
                  overflow: TextOverflow.ellipsis)),
        ]),
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMine = msg['is_mine'] == true;

                    return Align(
                      alignment:
                          isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Colors.indigoAccent
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMine
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMine
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          msg['message'] ?? '',
                          style: TextStyle(
                              color:
                                  isMine ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: Colors.white,
          child: SafeArea(
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: const CircleAvatar(
                  backgroundColor: Colors.indigoAccent,
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
