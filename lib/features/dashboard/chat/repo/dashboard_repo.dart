import 'package:fpdart/fpdart.dart';
import 'package:zenzen/data/api/chat_api.dart';
import 'package:zenzen/features/dashboard/chat/model/message_model.dart';

import '../../../../data/failure.dart';
import '../model/chat_model.dart';

class ChatDashboardRepository{
  final ChatService remoteDataSource;

  ChatDashboardRepository(this.remoteDataSource);

  Future<Either<List<ChatRoom>, ApiFailure>> getChatDashboard() {
    return remoteDataSource.getChatDashboard();
  }

  Future<Either<List<MessageModel>, ApiFailure>> getChatMessages(String roomId) {
    return remoteDataSource.getChatforRoom(roomId);
  }
}