import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/session/session_manager.dart';
import '../dashboard/app_colors.dart';
import 'message_model.dart';
import 'messages_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen ({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageService _service = MessageService();
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  Timer? _pollTimer;

  int? _relationshipId;
  int? _myId;

  bool _loading = true;
  String? _error;

  final List<ChatMessage> _messages = [];
  int _lastMessageId = 0;

  @override
  void initState(){
    super.initState();
    _initAndLoad();
  }

  @override
  void dispose(){
    _pollTimer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final relId = await SessionManager.getRelationshipId();
    final myId = await SessionManager.getUserId(); //caregiver user id

    if(!mounted) return;

    if (relId == null || myId == null){
      await SessionManager.debugPrintSession(tag: "MESSAGES");
      setState(() {
        _loading = false;
        _error = "Missing relationship_id or user_id. Please login again.";
      });
      return;
    }

    _relationshipId = relId;
    _myId = myId;

    await _loadInitial();

    //Poll (realtime)
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _pollNew());
  }

  Future<void> _loadInitial() async {
    try{
      final data = await _service.getMessages(
        relationshipId: _relationshipId!,
        afterId: 0,
        limit: 200,
      );

      final list = (data["messages"] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages
          ..clear()
          ..addAll(list);
        _lastMessageId = _messages.isNotEmpty ? _messages.last.messageId : 0;
        _loading = false;
        _error = null;
      });

      await _markIncomingAsRead(list);
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pollNew() async {
    if (_relationshipId == null || _myId == null) return;

    try {
      final data = await _service.getMessages(
        relationshipId: _relationshipId!,
        afterId: _lastMessageId,
        limit: 200,
      );

      final list = (data["messages"] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) return;

      setState(() {
        for (final msg in list){
          final exists = _messages.any((m) => m.messageId == msg.messageId);
          if(!exists){
            _messages.add(msg);
          }
        }

        if(_messages.isNotEmpty){
          _lastMessageId = _messages.last.messageId;
        }
      });

      await _markIncomingAsRead(list);
      _scrollToBottom();
    } catch (_) {

    }
  }

    Future<void> _markIncomingAsRead(List<ChatMessage> newMessages) async{
      if(_relationshipId == null || _myId == null) return;

      final incomingUnreadIds = newMessages
          .where((m) => m.senderId != _myId && m.isRead == false)
          .map((m) => m.messageId)
          .toList();

      if (incomingUnreadIds.isEmpty) return;

      try{
        await _service.markRead(
          relationshipId: _relationshipId!,
          readerId: _myId!,
          messageIds: incomingUnreadIds,
        );
      } catch (_) {
        //ignore
      }
    }

    Future<void> _send() async{
      final text = _textCtrl.text.trim();
      if (text.isEmpty) return;

      if(_relationshipId == null || _myId == null) return;

      FocusScope.of(context).unfocus();
      _textCtrl.clear();

      try{
        await _service.sendMessage(
          relationshipId: _relationshipId!,
          senderId: _myId!,
          messageText: text,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    void _scrollToBottom() {
      if(!_scrollCtrl.hasClients) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(!_scrollCtrl.hasClients) return;
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.containerBg,
          elevation: 0,
          title: const Text(
            "Messages",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actions: [
            IconButton(
              onPressed: _initAndLoad,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),

        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _errorView()
                : Column(
                    children: [
                      Expanded(child: _messagesList()),
                      _composer(),
                    ],
                  ),
      );
    }

    Widget _errorView() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Couldn't load messages",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _initAndLoad,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    Widget _messagesList() {
      return ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        itemCount: _messages.length,
        itemBuilder: (_, i){
          final m = _messages[i];
          final isMe = (m.senderId == _myId);

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.containerBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    m.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(m.sentAt),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    String _timeLabel(DateTime dt) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return "$h:$m";
    }

    Widget _composer(){
      return SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.containerBg,
            border: Border(
              top: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textCtrl,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Type a message...",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _send,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
