import 'package:collection/collection.dart';
import 'package:misskey_dart/misskey_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../model/account.dart';
import 'misskey_provider.dart';

part 'chat_history_notifier_provider.g.dart';

@riverpod
class ChatHistoryNotifier extends _$ChatHistoryNotifier {
  @override
  FutureOr<List<ChatMessage>> build(Account account) async {
    final misskey = ref.watch(misskeyProvider(account));
    final history = await Future.wait([
      misskey.chat.history(const ChatHistoryRequest(limit: 30, room: false)),
      misskey.chat.history(const ChatHistoryRequest(limit: 30, room: true)),
    ]);

    // Customization: Pin user 'aliya' to top of chat history
    return _sortWithPinnedUser(
      history.flattenedToList.sorted(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      ),
    );
  }

  // Customization: Sort messages with 'aliya' user pinned to top
  List<ChatMessage> _sortWithPinnedUser(List<ChatMessage> messages) {
    const pinnedUsername = 'aliya';
    
    final pinnedMessages = <ChatMessage>[];
    final otherMessages = <ChatMessage>[];
    
    for (final message in messages) {
      final fromUser = message.fromUser;
      final toUser = message.toUser;
      
      // Check if this conversation involves the pinned user
      final involvesPinnedUser = 
          (fromUser?.username == pinnedUsername) ||
          (toUser?.username == pinnedUsername);
      
      if (involvesPinnedUser) {
        pinnedMessages.add(message);
      } else {
        otherMessages.add(message);
      }
    }
    
    // Sort pinned messages by time (most recent first), then other messages
    pinnedMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return [...pinnedMessages, ...otherMessages];
  }

  void updateHistory(ChatMessage message) {
    state = AsyncValue.data([
      message.copyWith(isRead: false),
      ...?state.value?.where(
        (e) =>
            (message.toRoomId != null && e.toRoomId != message.toRoomId) ||
            (e.toUserId != message.toUserId &&
                e.toUserId != message.fromUserId),
      ),
    ]);
  }

  void read(String messageId) {
    if (state.value case final value?) {
      state = AsyncValue.data(
        value
            .map(
              (message) => message.id == messageId
                  ? message.copyWith(isRead: true)
                  : message,
            )
            .toList(),
      );
    }
  }
}
