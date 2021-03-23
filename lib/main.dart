import 'dart:async';
import 'package:quick_actions/quick_actions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;
import 'package:provider/provider.dart';
import 'package:safety/services/calls_and_messages_service.dart';
import 'package:safety/services/service_locator.dart';
import 'package:safety/shared/constants.dart';
import 'package:safety/pages/photo_capture.dart';
import 'package:safety/providers/profile_provider.dart';
import 'package:safety/services/service_locator.dart';
import 'package:safety/shared/constants.dart';
import 'package:safety/ui/splash.dart';
import 'package:safety/utils/routes.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _latestHardwareButtonEvent;
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();
  String shortcut = "no action set";
  final String number = "123456789";
  final String email = "dancamdev@example.com";


  StreamSubscription<HardwareButtons.VolumeButtonEvent> _volumeButtonSubscription;

  StreamSubscription<HardwareButtons.HomeButtonEvent> _homeButtonSubscription;

  StreamSubscription<HardwareButtons.LockButtonEvent> _lockButtonSubscription;

  @override
  void initState() {
    super.initState();

    final QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {

      if (shortcutType == 'action_one') {
        _service.sendSms(number);
      } else {
      _service.call(number);
      }
      setState(() {
        if (shortcutType != null) {
          shortcut = shortcutType;
        }
      });
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      // NOTE: This first action icon will only work on iOS.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
        type: 'action_one',
        localizedTitle: 'Emergency Message',
        icon: 'AppIcon',
      ),
      // NOTE: This second action icon will only work on Android.
      // In a real world project keep the same file name for both platforms.
      const ShortcutItem(
          type: 'action_two',
          localizedTitle: 'Emergency Call',
          icon: 'AppIcon'),
    ]).then((value) {
      setState(() {
        shortcut = "actions ready";
      });
    });
    _volumeButtonSubscription = HardwareButtons.volumeButtonEvents.listen((event) {
      setState(() {
        // _latestHardwareButtonEvent = event.toString();
        Constants.sendMessage();
      });
    });

    _homeButtonSubscription = HardwareButtons.homeButtonEvents.listen((event) {
      setState(() {
        // _latestHardwareButtonEvent = 'HOME_BUTTON';
        Constants.sendMessage();
      });
    });

    _lockButtonSubscription = HardwareButtons.lockButtonEvents.listen((event) {
      setState(() {
        // _latestHardwareButtonEvent = 'LOCK_BUTTON';
        Navigator.pushNamed(context, PhotoCapture.route);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _volumeButtonSubscription?.cancel();
    _homeButtonSubscription?.cancel();
    _lockButtonSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (BuildContext context) {
        return ProfileProvider();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SheHeroes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: Routes().getRoutes(),
        navigatorKey: appNavigator.navigatorKey,
        home: Splash(),
      ),
    );
  }
}
