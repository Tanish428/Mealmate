import 'package:flutter/material.dart';
import '../../models/ui/ui_member_model.dart';
import '../../models/ui/notice_model.dart';
import '../../models/ui/analytics_model.dart';

class MockUIRepos {
  static final List<UIMemberModel> members = [
    const UIMemberModel(
      id: '1',
      name: 'Aarav Patel',
      avatarInitials: 'AP',
      avatarColor: Colors.blue,
      dietaryPreference: 'Veg',
      paymentStatus: 'Fees Paid',
    ),
    const UIMemberModel(
      id: '2',
      name: 'Riya Sharma',
      avatarInitials: 'RS',
      avatarColor: Colors.pink,
      dietaryPreference: 'Veg',
      paymentStatus: 'Payment Due',
    ),
    const UIMemberModel(
      id: '3',
      name: 'Kabir Singh',
      avatarInitials: 'KS',
      avatarColor: Colors.green,
      dietaryPreference: 'Non-Veg',
      paymentStatus: 'Fees Paid',
    ),
    const UIMemberModel(
      id: '4',
      name: 'Ananya Desai',
      avatarInitials: 'AD',
      avatarColor: Colors.orange,
      dietaryPreference: 'Veg',
      paymentStatus: 'Fees Paid',
    ),
    const UIMemberModel(
      id: '5',
      name: 'Rohan Gupta',
      avatarInitials: 'RG',
      avatarColor: Colors.purple,
      dietaryPreference: 'Veg',
      paymentStatus: 'Payment Due',
    ),
  ];

  static final List<NoticeModel> notices = [
    const NoticeModel(
      id: '1',
      title: 'Mess Timing Update',
      body: 'Please note that lunch will be served 30 minutes late today due to maintenance.',
      timestamp: 'Today, 9:00 AM',
      iconType: Icons.campaign,
      isRead: false,
    ),
    const NoticeModel(
      id: '2',
      title: 'Holiday Closure',
      body: 'The mess will remain closed tomorrow evening for the festival.',
      timestamp: 'Yesterday, 4:00 PM',
      iconType: Icons.event,
      isRead: true,
    ),
  ];

  static const AnalyticsModel analytics = AnalyticsModel(
    totalFoodSaved: '145 kg',
    totalCostSaved: '₹8,250',
    averageOptOuts: '12 Members',
    mostSkippedMeal: 'Sunday Dinner',
    busiestDay: 'Wednesday',
    weeklyStandardCapacity: [50, 50, 50, 50],
    weeklyActualPrep: [42, 38, 40, 36],
  );
}
