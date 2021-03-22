import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gms_collector/screens/main_screen.dart';
import 'package:gms_collector/service/auth_service.dart';
import 'package:gms_collector/widgets/custom_auth_button.dart';
import 'package:gms_collector/widgets/custom_loading.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoad = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  userSignIn() async {
    if (phoneController.text.trim().length == 10) {
      AuthService authService = AuthService();
      bool response = await authService.signIn(
          phoneController.text.trim(), passwordController.text.trim());
      if (response) {
        Get.offAll(MainScreen());
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
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: "Mobile Number",
                        hintText: "Enter your mobile number",
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Container(
                    child: TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password"),
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
