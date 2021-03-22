import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gms_collector/screens/login_screen.dart';
import 'package:gms_collector/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkLogin() {
    GetStorage box = GetStorage();
    if (box.hasData("token")) {
      Get.offAll(MainScreen());
    } else {
      Get.offAll(LoginScreen());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/logo.png",
                ),
              ),
            ),
            SizedBox(
              height: Get.height * 0.01,
            ),
            Text(
              "GMS",
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                  letterSpacing: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}
