import 'package:bluetooth_demo/view/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isHideBtn = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      isHideBtn = true;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Image.asset('assets/bluetooth.gif'),
          const Spacer(),
          isHideBtn
              ? CircleAvatar(
                  backgroundColor: const Color(0xE5E59234),
                  radius: 30,
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                            (route) => false);
                      },
                      icon: const Icon(Icons.arrow_forward_outlined)))
              : const Spacer(),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
