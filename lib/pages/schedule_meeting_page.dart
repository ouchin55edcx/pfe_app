import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'meeting_provider.dart';
import '../widgets/NotificationBell.dart'; 
import 'notifications_page.dart';
import '../widgets/user_avatar.dart';
import 'UserProfilePage.dart';
import 'MeetingListPage.dart';

class ScheduleMeetingPage extends StatelessWidget {
  const ScheduleMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MeetingListPage(); // Change this to show MeetingListPage first
  }
}
