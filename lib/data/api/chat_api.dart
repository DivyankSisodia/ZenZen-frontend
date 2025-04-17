import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/failure.dart';
import 'package:zenzen/features/dashboard/chat/model/chat_model.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';

import '../local_data.dart';

class ChatService {
  final String baseUrl;
  final Dio dio;
  final TokenManager tokenManager;
  ChatService(this.baseUrl, this.dio, this.tokenManager);

  Future<Either<List<ChatRoom>, ApiFailure>> getChatDashboard() async {
    try {
      final token = await tokenManager.getAccessToken();
      final response = await dio.get(
        cancelToken: CancelToken(),
        '$baseUrl/chat/chat-dashboard',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('API Response status: ${response.statusCode}');
      print('API Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          final List<dynamic> chatsJson = responseData['message'];

          final List<ChatRoom> chats = chatsJson.map((chat) => ChatRoom.fromJson(chat)).toList();

          return Left(chats);
        } else {
          return Right(ApiFailure.custom(responseData['message']?.toString() ?? 'Unknown error'));
        }
      } else {
        return Right(ApiFailure.custom('Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      print('DioException in getChatDashboard: $e');
      return Right(ApiFailure.fromDioException(e));
    } catch (e) {
      print('Error in getChatDashboard: $e');
      return Right(ApiFailure.custom(e.toString()));
    }
  }

  Future<Either<List<MessageModel>, ApiFailure>> getChatforRoom(String roomId) async {
    try {
      final token = await tokenManager.getAccessToken();

      final response = await dio.post(
        cancelToken: CancelToken(),
        '$baseUrl/chat/get-chats',
        data: {
          'roomId': roomId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          final List<dynamic> messagesJson = responseData['data'];
          final List<MessageModel> messages = [];

          for (var message in messagesJson) {
            // Check if the message is a Map before trying to convert it
            if (message is Map<String, dynamic>) {
              messages.add(MessageModel.fromJson(message));
            } else {
              debugPrint('Skipping invalid message format: $message');
              // Optionally, you can handle this case differently if needed
            }
          }

          return Left(messages);
        } else {
          return Right(ApiFailure.custom(responseData['data']?.toString() ?? 'Unknown error'));
        }
      } else {
        return Right(ApiFailure.custom('Server error: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      print('DioException in chatMessages: $e');
      return Right(ApiFailure.fromDioException(e));
    } catch (e) {
      print('Error in getChatMessages: $e');
      return Right(ApiFailure.custom(e.toString()));
    }
  }
}
