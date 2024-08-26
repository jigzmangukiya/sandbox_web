import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sandbox_demo/modules/auth/login_screen.dart';
import 'package:sandbox_demo/modules/auth/signup_screen.dart';
import 'package:sandbox_demo/modules/dashboard/admin/admin_main_screen.dart';
import 'package:sandbox_demo/modules/dashboard/user/user_main_screen.dart';
import 'package:sandbox_demo/services/global_data.dart';
import 'package:sandbox_demo/services/navigation_service.dart';
import 'package:sandbox_demo/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initialization;
  final NavigationService _navigationService = locator<NavigationService>();

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  Future<void> _initializeApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? role = prefs.getString('userRole');
    String? token = prefs.getString('authToken');

    if (isLoggedIn && role != null && token != null) {
      final globalData = Provider.of<GlobalData>(context, listen: false);
      globalData.setUserToken(authToken: token);
      globalData.login(prefs.getString('userId')!, role);

      String route = (role == 'admin') ? AdminMainScreen.route : UserMainScreen.route;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GlobalData>(create: (_) => GlobalData()),
      ],
      child: MaterialApp(
        title: 'Your App Title',
        navigatorKey: locator<NavigationService>().navigatorKey,
        theme: ThemeData(primarySwatch: Colors.blue, scaffoldBackgroundColor: Colors.white, fontFamily: 'Poppins_Regular'),
        routes: {
          LoginScreen.route: (_) => LoginScreen(),
          SignUpScreen.route: (_) => SignUpScreen(),
          AdminMainScreen.route: (_) => AdminMainScreen(),
          UserMainScreen.route: (_) => UserMainScreen(),
        },
        home: FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LoginScreen(); // Default screen if no session
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
