import 'package:flutter/material.dart';
import 'package:strong_buddies_connect/home/home_page.dart';
import 'package:strong_buddies_connect/routes.dart';
import 'package:strong_buddies_connect/shared/services/auth/auth_service.dart';
import 'package:strong_buddies_connect/shared/services/location_service.dart';
import 'package:strong_buddies_connect/shared/services/user_collection.dart';
import 'package:strong_buddies_connect/themes/main_theme.dart';
import 'authentication/login/login_page.dart';
import 'authentication/login_with_phone/login_with_phone.dart';
import 'register/pages/newRegister/register_page.dart';
import 'package:strong_buddies_connect/chatList/chatList.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'matching/matching_page.dart';
import 'shared/utils/navigation_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final startPage = await handleInitialConfig();
  runApp(MaterialApp(
    home: MyApp(startPage: startPage),
    debugShowCheckedModeBanner: false,
  ));
}

Future<String> handleInitialConfig() async {
  final result =
      await Future.wait<dynamic>([askToTurnOnGps(), getInitialPage()]);
  return result[1];
}

Future<void> askToTurnOnGps() async {
  final location = LocationService();
  return location.handlePermissions();
}

Future<String> getInitialPage() async {
  final auth = AuthService();
  final userRepository = UserCollection();
  final user = await auth.getCurrentUser();
  if (user == null) return Routes.loginPage;
  final userInfo = await userRepository.getCurrentUserInfo(user.uid);

  return getNavigationRouteBasedOnUserState(userInfo);
}

class MyApp extends StatefulWidget {
  final String startPage;
  const MyApp({startPage: '/'}) : this.startPage = startPage;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      try {
        final Map<dynamic, dynamic> data = message['data'];
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: new Text("You have a match"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.network(data['photoUrl'], height: 200),
                  Text(data['displayName'])
                ],
              ),
              actions: <Widget>[
                RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Ok'),
                )
              ],
            );
          },
        );
      } catch (e) {
        print(e);
      }
    }, onLaunch: (Map<String, dynamic> message) async {
      Navigator.pushNamed(context, Routes.chatListPage);
    }, onResume: (Map<String, dynamic> message) async {
      Navigator.pushNamed(context, Routes.chatListPage);
    });

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 375, height: 812, allowFontScaling: true);
    return MaterialApp(
        initialRoute: this.widget.startPage,
        routes: {
          Routes.loginPage: (context) => LoginPage(),
          Routes.matchPage: (context) => HomePage(),
          Routes.loginPagePhoneNumber: (context) => LoginWithPhoneNumberPage(),
          Routes.registerPage: (context) => RegisterPageNew(),          
          Routes.chatListPage: (context) => ChatList()
        },
        theme: buildAppTheme());
  }
}
