import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gms_collector/screens/main_screen.dart';
import 'package:gms_collector/widgets/custom_auth_button.dart';
import 'package:gms_collector/widgets/custom_loading.dart';
import 'package:gms_core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoad = false;
  TextEditingController passcodeController = TextEditingController();

  userSignIn() async {
    if (passcodeController.text.trim().length > 2) {
      isLoad = true;
      setState(() {});
      AuthService authService = AuthService();
      bool response =
          await authService.collectorSignIn(passcodeController.text.trim());
      isLoad = true;
      setState(() {});
      if (response) {
        Get.offAll(MainScreen());
      } else {
        Get.rawSnackbar(message: "Invalid credentials");
      }
    } else {
      Get.rawSnackbar(message: "Invalid credentials");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: isLoad
          ? CustomLoading()
          : Container(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.08),
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
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Container(
                    child: TextField(
                      controller: passcodeController,
                      decoration: InputDecoration(
                          labelText: "Passcode",
                          hintText: "Enter your passcode"),
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.03,
                  ),
                  CustomAuthButton(
                    onTap: () => userSignIn(),
                    title: "SIGN IN",
                  )
                ],
              ),
            ),
    );
  }
}
