import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gms_collector/data/custom_constants.dart';

class NotificationService {
  Dio dio = new Dio();
  String serverCode = CustomConstants.notificationServerCode;

  Future sendNotificationToUser(
    String title,
    String message,
    String userId,
    Map data,
  ) async {
    await dio.post(
      "https://fcm.googleapis.com/fcm/send",
      data: {
        "notification": {
          "title": title,
          "body": message,
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        },
        "to": "/topics/$userId",
        "data": data
      },
      options: Options(
        headers: {
          HttpHeaders.authorizationHeader: serverCode,
        },
      ),
    );
    return;
  }
}
