import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/chat_model.dart';
import 'package:khdmti_project/models/message_model.dart';
import 'package:khdmti_project/models/profile_model.dart';
import 'package:khdmti_project/models/user_post_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DataBase {
  final supabase = Supabase.instance.client;

  // ── Stream all chats for current user ─────────────────────
  Stream<List<ChatModel>> streamUserChats() {
    final currentUserId = Auth.getUserId()!;

    final streamAsUser1 = supabase
        .from('chats')
        .stream(primaryKey: ['idChat'])
        .eq('idUser1', currentUserId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(ChatModel.fromJson).toList());

    final streamAsUser2 = supabase
        .from('chats')
        .stream(primaryKey: ['idChat'])
        .eq('idUser2', currentUserId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(ChatModel.fromJson).toList());

    return Rx.combineLatest2<List<ChatModel>, List<ChatModel>, List<ChatModel>>(
      streamAsUser1,
      streamAsUser2,
      (chatsAsUser1, chatsAsUser2) {
        final seen = <String>{};
        final merged = [...chatsAsUser1, ...chatsAsUser2]
            .where((chat) => seen.add(chat.idChat))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return merged;
      },
    );
  }

  // ── Stream messages for a specific chat ───────────────────
  Stream<List<MessageModel>> streamMessages(String idChat) {
    return supabase
        .from('message')
        .stream(primaryKey: ['id'])
        .eq('idChat', idChat)
        .order('created_at', ascending: true)
        .map((rows) => rows
            .where((r) => r['isDeleted'] == false)
            .map(MessageModel.fromJson)
            .toList());
  }

  // ── Get or create a chat (duplicate-safe) ─────────────────
  Future<String> getOrCreateChat({
    required String userId1,
    required String userId2,
  }) async {
    // .limit(1) guards against the 406 error if duplicate rows exist
    final existing = await supabase
        .from('chats')
        .select('idChat')
        .or('and(idUser1.eq.$userId1,idUser2.eq.$userId2),'
            'and(idUser1.eq.$userId2,idUser2.eq.$userId1)')
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return existing['idChat'] as String;
    }

    final newChat = await supabase
        .from('chats')
        .insert({'idUser1': userId1, 'idUser2': userId2})
        .select('idChat')
        .maybeSingle(); // maybeSingle avoids 406 on edge cases

    return newChat!['idChat'] as String;
  }

  // ── Send a message ────────────────────────────────────────
  // Only insert 'idChat' + 'content'.
  // idSender  → auto-filled by DB default auth.uid()
  // isDeleted → auto-filled by DB default false
  Future<void> sendMessage({
    required String userId1,
    required String userId2,
    required String content,
  }) async {
    final idChat = await getOrCreateChat(
      userId1: userId1,
      userId2: userId2,
    );

    await supabase.from('message').insert({
      'idChat': idChat,
      'content': content.trim(),
    });
  }

  // ── Soft delete a message ─────────────────────────────────
  Future<void> deleteMessage(int messageId) async {
    await supabase
        .from('message')
        .update({'isDeleted': true}).eq('id', messageId);
  }

  // ── Fetch last non-deleted message preview ────────────────
  Future<MessageModel?> fetchLastMessage(String idChat) async {
    final result = await supabase
        .from('message')
        .select()
        .eq('idChat', idChat)
        .eq('isDeleted', false)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return result != null ? MessageModel.fromJson(result) : null;
  }

  // ── Fetch a user profile ──────────────────────────────────
  Future<UserProfileModel> fetchProfile(String userId) async {
    final json =
        await supabase.from('userProfile').select().eq('id', userId).single();
    return UserProfileModel.fromJson(json);
  }

  // ── Legacy profile fetch ──────────────────────────────────
  Future<UserProfileModel> profileData({required String value}) async {
    final response =
        await supabase.from('userProfile').select().eq('id', value).single();
    return UserProfileModel.fromJson(response);
  }

  // ── Insert new user profile on signup ────────────────────
  Future<void> insertToDataBase(AuthResponse userData) async {
    final profile = UserProfileModel(
      id: userData.user!.id,
      jobTitle: "Job",
      description: "Hello My Name ${userData.user!.userMetadata!["name"]}",
      skills: "",
      completedProject: 0,
      succesProject: 0,
      numberofYearsExperince: 0,
    );
    await supabase.from('userProfile').insert(profile.toJson());
  }

  // ── Insert a new post ─────────────────────────────────────
  Future<void> insertToUserPost(UserPostModel post) async {
    await supabase.from('userPost').insert(post.toJson());
  }
}
