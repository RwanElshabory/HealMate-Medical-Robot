import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../models/chat_message_model.dart';

class ChatApiService {
  Future<List<ChatMessageModel>> getHistory(int userA, int userB) async {
    final response = await ApiClient.dio.get(
      "${Endpoints.chatHistory}/$userA/$userB",
      queryParameters: {
        "page": 1,
        "pageSize": 50,
      },
    );

    final List messages = response.data["messages"] ?? [];
    return messages.map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  Future<ChatMessageModel> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
  }) async {
    final response = await ApiClient.dio.post(
      Endpoints.chatSend,
      data: {
        "senderId": senderId,
        "receiverId": receiverId,
        "type": "text",
      },
    );

    return ChatMessageModel.fromJson(response.data);
  }

  Future<void> markAsRead(List<int> ids) async {
    await ApiClient.dio.post(
      Endpoints.chatMarkAsRead,
      data: ids,
    );
  }
}