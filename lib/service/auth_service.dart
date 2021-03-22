import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gms_collector/data/custom_constants.dart';

class AuthService {
  Future<bool> signIn(String phone, String password) async {
    Dio dio = new Dio();

    try {
      Response response = await dio.post(
        "${CustomConstants.url}signIn",
        data: {
          'collector_password': password,
          "collector_phone": phone,
        },
      );

      print(response.data);

      if (response.data['success'] &&
          response.data['message'] == "Signin successfull") {
        GetStorage box = GetStorage();
        box.write("token", response.data['token']);
        box.write("collector_id", response.data['collector_id'].toString());
        box.write("collector_name", response.data['collector_name'].toString());
        box.write(
            "collector_photo", response.data['collector_photo'].toString());
        box.write(
            "collector_phone", response.data['collector_phone'].toString());
        return true;
      } else {
        Get.rawSnackbar(message: "Invalid Credentials");
        return false;
      }
    } catch (e) {
      Get.rawSnackbar(message: "Oops! Something went wrong");
      return false;
    }
  }
}
