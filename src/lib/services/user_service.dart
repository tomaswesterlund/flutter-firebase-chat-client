import 'package:uuid/uuid.dart';

class UserService {
  static String userId = const Uuid().v4();

  bool isMe(String userId) {
    return userId == UserService.userId;
  }
}