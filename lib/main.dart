import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'pages/LoginPage.dart';
import 'pages/meeting_provider.dart';
import 'pages/schedule_meeting_page.dart';
import 'services/auth_service.dart';

void main() {
  // Initialize Get services
  Get.put(AuthService());

  runApp(GestionSyndicApp());
}

class GestionSyndicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MeetingProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: LoginPage(),
      ),
    );
  }
}
