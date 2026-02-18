import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/db/database/db.dart';
import 'package:khdmti_project/models/chat_model.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';

class MessageController with ChangeNotifier {
  final DataBase _db = DataBase();

  // ── State ──
  List<MessageModel> messages = [];
  List<ChatModel> chats = [];
  bool isLoading = false;
  String? error;

  // ── Streams ──
  Stream<List<ChatModel>> get chatsStream => _db.streamUserChats();
  Stream<List<MessageModel>> messagesStream(String idChat) =>
      _db.streamMessages(idChat);

  // ── Get the other user's id in a chat ──
  String? getOtherUserId(ChatModel chat) {
    final currentUserId = Auth.getUserId()!;
    return chat.idUser1 == currentUserId ? chat.idUser2 : chat.idUser1;
  }

  // ── Send message ──
  Future<void> sendMessage({
    required String userId2,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;
    final userId1 = Auth.getUserId()!;
    try {
      await _db.sendMessage(
        userId1: userId1,
        userId2: userId2,
        content: content.trim(),
      );
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ── Delete message ──
  Future<void> deleteMessage(int messageId) async {
    try {
      await _db.deleteMessage(messageId);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // ── Fetch profile ──
  Future<UserProfileModel> fetchProfile(String userId) {
    return _db.fetchProfile(userId);
  }

  // ── Fetch last message preview ──
  Future<MessageModel?> fetchLastMessage(String idChat) {
    return _db.fetchLastMessage(idChat);
  }

  // ── Format timestamp ──
  String formatTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
