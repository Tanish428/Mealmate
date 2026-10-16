import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'package:mealmate/ui/auth/login_screen.dart';
import 'package:mealmate/ui/auth/signup_screen.dart';
import 'package:mealmate/ui/auth/role_selection_screen.dart';
import 'package:mealmate/ui/member/join_mess_screen.dart';
import 'package:mealmate/ui/owner/create_mess_screen.dart';
import 'package:mealmate/ui/member/member_home_screen.dart';
import 'package:mealmate/ui/member/menu_view_screen.dart';
import 'package:mealmate/ui/member/attendance_toggle_screen.dart';
import 'package:mealmate/ui/member/profile_screen.dart';
import 'package:mealmate/ui/member/edit_profile_screen.dart';
import 'package:mealmate/ui/member/feedback_screen.dart';
import 'package:mealmate/ui/member/notice_board_screen.dart';
import 'package:mealmate/ui/owner/owner_dashboard_screen.dart';
import 'package:mealmate/ui/owner/menu_manager_screen.dart';
import 'package:mealmate/ui/owner/members_screen.dart';
import 'package:mealmate/ui/owner/mess_profile_screen.dart';
import 'package:mealmate/ui/owner/meal_timings_screen.dart';
import 'package:mealmate/ui/owner/preparation_planner_screen.dart';
import 'package:mealmate/ui/owner/surplus_allocation_screen.dart';
import 'package:mealmate/ui/owner/waste_reports_screen.dart';
import 'package:mealmate/ui/owner/broadcast_screen.dart';
import 'package:mealmate/ui/owner/owner_feedback_screen.dart';

// Models & Controllers for injection
import 'package:mealmate/data/models/analytics_model.dart';
import 'package:mealmate/data/models/models.dart';
import 'package:mealmate/data/repos/analytics_repo.dart';
import 'package:mealmate/data/repos/mess_repo.dart';
import 'package:mealmate/data/repos/surplus_repo.dart';
import 'package:mealmate/logic/controllers/analytics_controller.dart';
import 'package:mealmate/logic/controllers/surplus_controller.dart';

// --- MOCK STORAGE & CLIENT ---
class MockUserLocalStorage extends LocalStorage {
  final String sessionString;
  const MockUserLocalStorage(this.sessionString);

  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async => sessionString;
  @override
  Future<bool> hasAccessToken() async => true;
  @override
  Future<void> persistSession(String persistSessionString) async {}
  @override
  Future<void> removePersistedSession() async {}
}

class MockAsyncStorage extends GotrueAsyncStorage {
  const MockAsyncStorage();
  @override
  Future<String?> getItem({required String key}) async => null;
  @override
  Future<void> removeItem({required String key}) async {}
  @override
  Future<void> setItem({required String key, required String value}) async {}
}

class MealMateMockHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('HTTP REQUEST: ${request.method} ${request.url}');
    final path = request.url.path;
    final query = request.url.query;
    dynamic jsonResult = [];

    if (path.contains('profiles')) {
      if (query.contains('id=eq.mock-user-1') && !query.contains('mess_id=')) {
        jsonResult = [
          {
            'id': 'mock-user-1',
            'full_name': 'Rahul Sharma',
            'role': 'member',
            'mess_id': 'mess-001',
            'room_no': 'B-204',
            'phone': '+91 98765 43210',
            'diet_preference': 'Vegetarian',
            'created_at': '2026-01-15T08:00:00Z',
            'avatar_url': null,
            'messes': {
              'id': 'mess-001',
              'mess_name': 'Royal Feast Hostel Mess',
              'served_meals': ['breakfast', 'lunch', 'dinner'],
              'capacity': 150,
            }
          }
        ];
      } else {
        jsonResult = [
          {'id': 'mem-1', 'full_name': 'Rahul Sharma', 'room_no': 'B-204', 'phone': '+91 98765 43210', 'is_active': true, 'created_at': '2026-08-01', 'diet_preference': 'Vegetarian', 'mess_id': 'mess-001'},
          {'id': 'mem-2', 'full_name': 'Priya Patel', 'room_no': 'A-108', 'phone': '+91 98111 22334', 'is_active': true, 'created_at': '2026-08-05', 'diet_preference': 'Vegetarian', 'mess_id': 'mess-001'},
          {'id': 'mem-3', 'full_name': 'Aman Verma', 'room_no': 'C-312', 'phone': '+91 98222 33445', 'is_active': true, 'created_at': '2026-08-10', 'diet_preference': 'Non-Vegetarian', 'mess_id': 'mess-001'},
          {'id': 'mem-4', 'full_name': 'Sneha Kulkarni', 'room_no': 'B-115', 'phone': '+91 98333 44556', 'is_active': true, 'created_at': '2026-08-12', 'diet_preference': 'Vegetarian', 'mess_id': 'mess-001'},
          {'id': 'mem-5', 'full_name': 'Rohan Deshmukh', 'room_no': 'A-201', 'phone': '+91 98444 55667', 'is_active': true, 'created_at': '2026-08-15', 'diet_preference': 'Vegetarian', 'mess_id': 'mess-001'},
        ];
      }
    } else if (path.contains('messes')) {
      jsonResult = [
        {
          'id': 'mess-001',
          'mess_name': 'Royal Feast Hostel Mess',
          'invite_code': 'RFM789',
          'cost_per_meal': 60,
          'capacity': 150,
          'served_meals': ['breakfast', 'lunch', 'dinner'],
          'meal_timings': {
            'breakfast': {'start': '07:30', 'end': '09:30'},
            'lunch': {'start': '12:30', 'end': '14:30'},
            'dinner': {'start': '19:30', 'end': '21:30'},
          },
          'rules': '1. Mark meal opt-out before cutoff time.\n2. Do not waste food.',
          'owner_id': 'mock-user-1',
          'address': 'Block 4, University Campus, Pune',
        }
      ];
    } else if (path.contains('menus')) {
      final dateRegex = RegExp(r'menu_date=eq\.(\d{4}-\d{2}-\d{2})');
      final match = dateRegex.firstMatch(query);
      final reqDate = match?.group(1) ?? DateTime.now().toIso8601String().substring(0, 10);
      jsonResult = [
        {
          'id': 'menu-1',
          'mess_id': 'mess-001',
          'meal_type': 'breakfast',
          'menu_date': reqDate,
          'date': reqDate,
          'items': ['Masala Dosa', 'Sambar & Coconut Chutney', 'Boiled Eggs', 'Filter Coffee'],
          'image_url': null,
        },
        {
          'id': 'menu-2',
          'mess_id': 'mess-001',
          'meal_type': 'lunch',
          'menu_date': reqDate,
          'date': reqDate,
          'items': ['Paneer Butter Masala', 'Dal Makhani', 'Jeera Rice', 'Butter Roti', 'Green Salad', 'Gulab Jamun'],
          'image_url': null,
        },
        {
          'id': 'menu-3',
          'mess_id': 'mess-001',
          'meal_type': 'dinner',
          'menu_date': reqDate,
          'date': reqDate,
          'items': ['Aloo Gobi Matar', 'Yellow Dal Tadka', 'Steamed Rice', 'Chapati', 'Curd'],
          'image_url': null,
        },
      ];
    } else if (path.contains('broadcasts')) {
      jsonResult = [
        {
          'id': 'b-1',
          'mess_id': 'mess-001',
          'title': 'Festive Weekend Feast Announcement',
          'body': 'This Sunday dinner features special Paneer Tikka, Veg Biryani, and Rasmalai. Enjoy the feast!',
          'urgency': 'Normal',
          'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        },
        {
          'id': 'b-2',
          'mess_id': 'mess-001',
          'title': 'Water Maintenance in Dining Hall',
          'body': 'Dining hall water filter maintenance will take place on Saturday between 3 PM and 5 PM.',
          'urgency': 'Urgent',
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ];
    } else if (path.contains('feedback')) {
      jsonResult = [
        {
          'id': 'fb-1',
          'mess_id': 'mess-001',
          'meal_type': 'lunch',
          'rating': 5,
          'comment': 'The paneer butter masala today was extraordinarily delicious! Soft rotis too.',
          'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
          'profiles': {'full_name': 'Rahul Sharma', 'room_no': 'B-204'},
        },
        {
          'id': 'fb-2',
          'mess_id': 'mess-001',
          'meal_type': 'dinner',
          'rating': 4,
          'comment': 'Hot food served on time and great hygiene in the service area.',
          'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'profiles': {'full_name': 'Priya Patel', 'room_no': 'A-108'},
        },
        {
          'id': 'fb-3',
          'mess_id': 'mess-001',
          'meal_type': 'breakfast',
          'rating': 5,
          'comment': 'Crispy dosas and very fresh coconut chutney. Superb start to the day!',
          'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'profiles': {'full_name': 'Aman Verma', 'room_no': 'C-312'},
        },
      ];
    } else if (path.contains('skips')) {
      jsonResult = [
        {
          'id': 'skip-1',
          'user_id': 'mock-user-1',
          'mess_id': 'mess-001',
          'meal_type': 'dinner',
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'status': 'skipped',
        }
      ];
    } else {
      jsonResult = [];
    }

    final isSingleObject = request.headers['Accept']?.contains('vnd.pgrst.object') == true;
    final dynamic payload = isSingleObject
        ? (jsonResult is List ? (jsonResult.isNotEmpty ? jsonResult.first : {}) : jsonResult)
        : (jsonResult is List ? jsonResult : [jsonResult]);

    final bodyBytes = utf8.encode(jsonEncode(payload));
    return http.StreamedResponse(
      Stream.value(bodyBytes),
      200,
      request: request,
      headers: {
        'content-type': isSingleObject ? 'application/vnd.pgrst.object+json' : 'application/json',
        'content-range': '0-${jsonResult is List ? (jsonResult.isEmpty ? 0 : jsonResult.length - 1) : 0}/${jsonResult is List ? jsonResult.length : 1}',
      },
    );
  }
}

// Mock Analytics & Surplus Repos for deterministic high-value UI
class MockAnalyticsRepoForScreens extends AnalyticsRepository {
  final AnalyticsModel model;
  MockAnalyticsRepoForScreens(this.model);

  @override
  Future<AnalyticsModel> getAnalytics({
    required String messId,
    required String timeframe,
    int costPerMeal = 60,
    int messStandardCapacity = 150,
  }) async {
    return model;
  }
}

class FakeSurplusRepoForScreens implements SurplusRepository {
  @override
  Future<MealPrepRecordModel?> getMealPrepRecord({
    required String messId,
    required DateTime date,
    required String mealType,
  }) async {
    return MealPrepRecordModel(
      id: 'prep-rec-001',
      messId: messId,
      prepDate: date,
      mealType: mealType,
      targetPortions: 135,
      preparedPortions: 130,
      servedPortions: 118,
      discardedPortions: 2,
      surplusPortions: 12,
      costPerMeal: 60,
    );
  }

  @override
  Future<List<DonationPartnerModel>> getPartners({required String messId, bool activeOnly = true}) async {
    return [
      DonationPartnerModel(
        id: 'dp-1',
        messId: messId,
        name: 'Robin Hood Army - City Chapter',
        contactPhone: '+91 98765 00112',
        contactPerson: 'Suresh Patil',
        isActive: true,
      ),
      DonationPartnerModel(
        id: 'dp-2',
        messId: messId,
        name: 'Annakshetra Food Relief Trust',
        contactPhone: '+91 98765 00334',
        contactPerson: 'Kavita Joshi',
        isActive: true,
      ),
    ];
  }

  @override
  Future<List<SurplusAllocationModel>> getAllocationsForMeal({
    required String mealPrepRecordId,
  }) async {
    return [
      SurplusAllocationModel(
        id: 'alloc-1',
        messId: 'mess-001',
        mealPrepRecordId: mealPrepRecordId,
        partnerId: 'dp-1',
        partnerName: 'Robin Hood Army - City Chapter',
        quantity: 10,
        status: SurplusAllocationModel.statusCollected,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Future<int> getTotalMealsCollectedThisMonth(String messId) async => 145;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// --- FONT LOADER ---
Future<void> loadFonts() async {
  final materialIconsFile = File(r'C:\src\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf');
  if (materialIconsFile.existsSync()) {
    final bytes = materialIconsFile.readAsBytesSync();
    final fontLoader = FontLoader('MaterialIcons');
    fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await fontLoader.load();
  }

  final robotoFiles = [
    r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-regular.ttf',
    r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-bold.ttf',
    r'C:\src\flutter\bin\cache\artifacts\material_fonts\roboto-medium.ttf',
  ];
  final robotoLoader = FontLoader('Roboto');
  for (final path in robotoFiles) {
    final file = File(path);
    if (file.existsSync()) {
      robotoLoader.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
    }
  }
  await robotoLoader.load();

  final cupertinoFile = File(r'C:\Users\Lenovo\AppData\Local\Pub\Cache\hosted\pub.dev\cupertino_icons-1.0.9\assets\CupertinoIcons.ttf');
  if (cupertinoFile.existsSync()) {
    final loader = FontLoader('packages/cupertino_icons/CupertinoIcons');
    loader.addFont(Future.value(ByteData.view(cupertinoFile.readAsBytesSync().buffer)));
    await loader.load();
  }
}

// --- SMARTPHONE FRAME WRAPPER ---
Widget buildPhoneScreen({
  required Widget child,
  String time = '9:41',
  bool isDarkStatus = true,
  Widget? bottomBar,
}) {
  final statusColor = isDarkStatus ? const Color(0xFF1E1E1E) : Colors.white;

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC0392B),
        surface: const Color(0xFFFBF8F1),
      ),
    ),
    home: Material(
      color: const Color(0xFFFAF8F5),
      child: Column(
        children: [
          // Elegant Mobile Status Bar
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.signal_cellular_4_bar, size: 15, color: statusColor),
                    const SizedBox(width: 5),
                    Icon(Icons.wifi, size: 15, color: statusColor),
                    const SizedBox(width: 6),
                    Container(
                      width: 24,
                      height: 12,
                      decoration: BoxDecoration(
                        border: Border.all(color: statusColor, width: 1.2),
                        borderRadius: BorderRadius.circular(3.5),
                      ),
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Screen Body
          Expanded(child: child),
          // Bottom Bar if provided
          if (bottomBar != null) bottomBar,
        ],
      ),
    ),
  );
}

// Nav bar mock for Member
Widget buildMemberNavBar(int activeIndex) {
  const items = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Menu'),
    (Icons.event_available_outlined, Icons.event_available, 'Attendance'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];
  return Container(
    height: 64,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -3)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (idx) {
        final isSel = idx == activeIndex;
        final item = items[idx];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSel ? item.$2 : item.$1, color: isSel ? const Color(0xFFC0392B) : Colors.grey.shade500, size: 24),
            const SizedBox(height: 3),
            Text(
              item.$3,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? const Color(0xFFC0392B) : Colors.grey.shade600,
              ),
            ),
          ],
        );
      }),
    ),
  );
}

// Nav bar mock for Owner
Widget buildOwnerNavBar(int activeIndex) {
  const items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
    (Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Menu'),
    (Icons.people_outline, Icons.people, 'Members'),
    (Icons.storefront_outlined, Icons.storefront, 'Mess Profile'),
  ];
  return Container(
    height: 64,
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -3)),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(items.length, (idx) {
        final isSel = idx == activeIndex;
        final item = items[idx];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSel ? item.$2 : item.$1, color: isSel ? const Color(0xFFC0392B) : Colors.grey.shade500, size: 24),
            const SizedBox(height: 3),
            Text(
              item.$3,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? const Color(0xFFC0392B) : Colors.grey.shade600,
              ),
            ),
          ],
        );
      }),
    ),
  );
}

// Helper to capture and save a widget to disk
Future<void> captureWidget({
  required WidgetTester tester,
  required Widget widget,
  required String fileName,
}) async {
  try {
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: widget,
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 250));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image? image;
    ByteData? byteData;
    await tester.runAsync(() async {
      image = await boundary.toImage(pixelRatio: 1.0);
      byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
    });
    final bytes = byteData!.buffer.asUint8List();

    final outPath = 'screenshots/mobile/$fileName';
    File(outPath).writeAsBytesSync(bytes);
    print('CAPTURED: $outPath (${bytes.length} bytes)');
  } catch (e, stack) {
    print('ERROR CAPTURING $fileName: $e\n$stack');
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('overflowed by')) {
        return; // Suppress overflow warnings in screenshot test harness
      }
      FlutterError.presentError(details);
    };
    await loadFonts();

    final userJson = {
      'id': 'mock-user-1',
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'rahul.sharma@campus.edu',
      'user_metadata': {'full_name': 'Rahul Sharma', 'role': 'member'},
      'app_metadata': {'provider': 'email'},
    };
    final sessionMap = {
      'access_token': 'dummy.token',
      'token_type': 'bearer',
      'expires_in': 99999999,
      'refresh_token': 'dummy.refresh',
      'user': userJson,
    };

    await Supabase.initialize(
      url: 'https://hwujjjtqnambqfuxyyel.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3dWpqanRxbmFtYnFmdXh5eWVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk2NTE2OTEsImV4cCI6MjEwNTIyNzY5MX0.sI953Ibh3lyEVctkTAfhf2xMMjTRcVNkMtjD9uD-B5Q',
      httpClient: MealMateMockHttpClient(),
      authOptions: FlutterAuthClientOptions(
        localStorage: MockUserLocalStorage(jsonEncode(sessionMap)),
        pkceAsyncStorage: const MockAsyncStorage(),
        autoRefreshToken: false,
        persistSession: true,
        detectSessionInUri: false,
      ),
    );
  });

  testWidgets('Generate all MealMate Mobile Screenshots', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 01. Splash Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: Container(
          color: const Color(0xFFC0392B),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/MealMate_logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'MealMate',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart Mess & Food Management System',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
        isDarkStatus: false,
      ),
      fileName: '01_splash_screen.png',
    );

    // 02. Login Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const LoginScreen(),
      ),
      fileName: '02_login_screen.png',
    );

    // 03. Sign Up Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const SignupScreen(),
      ),
      fileName: '03_signup_screen.png',
    );

    // 04. Role Selection Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const RoleSelectionScreen(),
      ),
      fileName: '04_role_selection_screen.png',
    );

    // 05. Join Mess Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const JoinMessScreen(),
      ),
      fileName: '05_join_mess_screen.png',
    );

    // 06. Create Mess Screen
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const CreateMessScreen(),
      ),
      fileName: '06_create_mess_screen.png',
    );

    // 07. Member Home Dashboard
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MemberHomeScreen(),
        bottomBar: buildMemberNavBar(0),
      ),
      fileName: '07_member_home_dashboard.png',
    );

    // 08. Member Menu View
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MenuViewScreen(),
        bottomBar: buildMemberNavBar(1),
      ),
      fileName: '08_member_menu_view.png',
    );

    // 09. Member Attendance Toggle
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const AttendanceToggleScreen(),
        bottomBar: buildMemberNavBar(2),
      ),
      fileName: '09_member_attendance_toggle.png',
    );

    // 10. Member Profile
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const ProfileScreen(),
        bottomBar: buildMemberNavBar(3),
      ),
      fileName: '10_member_profile.png',
    );

    // 11. Member Edit Profile
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const EditProfileScreen(
          currentName: 'Rahul Sharma',
          currentEmail: 'rahul.sharma@campus.edu',
          assignedMess: 'Royal Feast Hostel Mess',
          currentRole: 'Mess Member',
        ),
      ),
      fileName: '11_member_edit_profile.png',
    );

    // 12. Member Feedback
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const FeedbackScreen(),
      ),
      fileName: '12_member_feedback.png',
    );

    // 13. Member Notice Board
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const NoticeBoardScreen(),
      ),
      fileName: '13_member_notice_board.png',
    );

    // 14. Owner Dashboard
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const OwnerDashboardScreen(),
        bottomBar: buildOwnerNavBar(0),
      ),
      fileName: '14_owner_dashboard.png',
    );

    // 15. Owner Menu Manager
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MenuManagerScreen(),
        bottomBar: buildOwnerNavBar(1),
      ),
      fileName: '15_owner_menu_manager.png',
    );

    // 16. Owner Members List
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MembersScreen(),
        bottomBar: buildOwnerNavBar(2),
      ),
      fileName: '16_owner_members_screen.png',
    );

    // 17. Owner Mess Profile
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MessProfileScreen(),
        bottomBar: buildOwnerNavBar(3),
      ),
      fileName: '17_owner_mess_profile.png',
    );

    // 18. Owner Meal Timings
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const MealTimingsScreen(),
      ),
      fileName: '18_owner_meal_timings.png',
    );

    // 19. Owner Preparation Planner
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const PreparationPlannerScreen(),
      ),
      fileName: '19_owner_preparation_planner.png',
    );

    // 20. Owner Surplus Allocation Screen
    final fakeSurplusRepo = FakeSurplusRepoForScreens();
    final surplusController = SurplusController(surplusRepo: fakeSurplusRepo);
    await surplusController.init();
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: SurplusAllocationScreen(controller: surplusController),
      ),
      fileName: '20_owner_surplus_allocation.png',
    );

    // 21. Owner Waste Reports & ROI
    const testAnalytics = AnalyticsModel(
      prepAccuracyPercentage: 96.4,
      ghostMealsPrevented: 362,
      mostSkippedMeal: 'Dinner',
      busiestDay: 'Sunday (Lunch)',
      timeframe: 'This Month',
      totalFoodSaved: '128 kg',
      totalCostSaved: '₹18,100',
      totalCostSavedValue: 18100,
      totalCostLost: 1250,
      surplusRecoveryRate: 92.5,
      totalTargetPortions: 2500,
      totalPreparedPortions: 2480,
      totalServedPortions: 2400,
      totalDiscardedPortions: 25,
      totalDonatedPortions: 310,
      totalMealSessions: 60,
      averageOptOuts: '8 members / meal',
    );
    final analyticsController = AnalyticsController(
      analyticsRepo: MockAnalyticsRepoForScreens(testAnalytics),
      messRepo: MessRepository(),
      autoLoad: false,
    );
    await analyticsController.loadAnalytics();
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: WasteReportsScreen(controller: analyticsController),
      ),
      fileName: '21_owner_waste_reports.png',
    );

    // 22. Owner Broadcast Announcements
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const BroadcastScreen(),
      ),
      fileName: '22_owner_broadcast.png',
    );

    // 23. Owner Feedback Reviews
    await captureWidget(
      tester: tester,
      widget: buildPhoneScreen(
        child: const OwnerFeedbackScreen(),
      ),
      fileName: '23_owner_feedback.png',
    );
  });
}
