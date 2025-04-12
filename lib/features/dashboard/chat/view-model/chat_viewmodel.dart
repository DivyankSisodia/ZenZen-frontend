import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/dashboard/chat/model/chat_model.dart';

class ChatViewModel extends StateNotifier<AsyncValue<List<ChatModel>>> {
  ChatViewModel() : super(const AsyncValue.loading());

  bool _isLoading = false;

  Future<void> getChats() async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      // For now, using dummy data
      final dummyChats = List.generate(
        20,
        (index) => ChatModel(
          id: 'chat_$index',
          userId: 'user_$index',
          userName: 'User $index',
          lastMessage: 'This is a sample message $index',
          lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
          isRead: index % 3 == 0,
          unreadCount: index % 3 == 0 ? 0 : index % 3,
        ),
      );

      state = AsyncValue.data(dummyChats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> searchChats(String query) async {
    if (_isLoading) return;

    _isLoading = true;
    state = const AsyncValue.loading();

    try {
      
      final dummyChats = List.generate(
        5,
        (index) => ChatModel(
          id: 'search_$index',
          userId: 'user_$index',
          userName: 'Search Result $index',
          lastMessage: 'Search result message $index',
          lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
          isRead: true,
          unreadCount: 0,
        ),
      );

      state = AsyncValue.data(dummyChats);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }
}

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, AsyncValue<List<ChatModel>>>((ref) {
  return ChatViewModel();
}); 