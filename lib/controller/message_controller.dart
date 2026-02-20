import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/db/database/db.dart';
import 'package:khdmti_project/models/chat_model.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';
import 'package:provider/provider.dart';

class MessageController with ChangeNotifier {
  final DataBase _db = DataBase();

  // ── State ──────────────────────────────────────────────────
  bool isLoading = false;
  String? error;

  // ── Streams ────────────────────────────────────────────────
  Stream<List<ChatModel>> get chatsStream => _db.streamUserChats();

  Stream<List<MessageModel>> messagesStream(String idChat) =>
      _db.streamMessages(idChat);

  // ── Get other user id from chat ────────────────────────────
  String? getOtherUserId(ChatModel chat) {
    final me = Auth.getUserId();
    return chat.idUser1 == me ? chat.idUser2 : chat.idUser1;
  }

  // ── Get or create a chat, return idChat UUID ───────────────
  Future<String> getOrCreateChat(String otherUserId) async {
    final me = Auth.getUserId()!;
    return await _db.getOrCreateChat(userId1: me, userId2: otherUserId);
  }

  // ── Send message ───────────────────────────────────────────
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
      debugPrint('sendMessage error: $e');
      notifyListeners();
    }
  }

  // ── Soft delete ────────────────────────────────────────────
  Future<void> deleteMessage(int messageId) async {
    try {
      await _db.deleteMessage(messageId);
    } catch (e) {
      error = e.toString();
      debugPrint('deleteMessage error: $e');
      notifyListeners();
    }
  }

  // ── Fetch other user's profile ─────────────────────────────
  Future<UserProfileModel> fetchProfile(String userId) =>
      _db.fetchProfile(userId);

  // ── Last message preview for chat list tile ────────────────
  Future<MessageModel?> fetchLastMessage(String idChat) =>
      _db.fetchLastMessage(idChat);

  // ── Format timestamp → Arabic-friendly string ──────────────
  String formatTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    final diff = DateTime.now().difference(date);

    if (diff.inDays == 0) {
      final h = date.hour.toString().padLeft(2, '0');
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ── Convenience: read controller from context ──────────────
  static MessageController of(BuildContext context) =>
      context.read<MessageController>();
}
