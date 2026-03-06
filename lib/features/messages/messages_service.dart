import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class MessageService {
  Future<Map<String, dynamic>> getMessages({
    required int relationshipId,
    int afterId = 0,
    int limit = 200,
  }) async {
    try {
      final res = await DioClient.dio.get(
        "/api/messages",
        queryParameters: {
          "relationship_id": relationshipId,
          "after_id": afterId,
          "limit": limit,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message ?? "Failed to get messages");
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required int relationshipId,
    required int senderId,
    required String messageText,
  }) async {
    try {
      final res = await DioClient.dio.post(
        "/api/messages/send",
        data: {
          "relationship_id": relationshipId,
          "sender_id": senderId,
          "message_text": messageText,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? e.message ?? "Failed to send message");
    }
  }

  Future<Map<String, dynamic>> markRead({
    required int relationshipId,
    required int readerId,
    required List<int> messageIds,
  }) async {
    if (messageIds.isEmpty) return {"status": "ok", "updated": 0};

    try{
      final res = await DioClient.dio.put(
        "/api/messages/read",
        data: {
          "relationship_id": relationshipId,
          "reader_id": readerId,
          "message_ids": messageIds,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e){
      throw Exception(e.response?.data ?? e.message ?? "Failed to mark read");
    }
  }
}