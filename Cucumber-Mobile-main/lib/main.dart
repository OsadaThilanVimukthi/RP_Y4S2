import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screen/screen.dart';
import 'config/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projectcucumber/provider/internet_provider.dart';
import 'package:projectcucumber/provider/sign_in_provider.dart';
import 'package:projectcucumber/screen/splash/splash_screen.dart';
import 'package:provider/provider.dart';

// Main entry point for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: 'lib/config/.env');
  runApp(const MyApp());
}

// Main application class
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject dependencies and build the application
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => SignInProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => InternetProvider()),
          ),
        ],
        child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) {
              return MaterialApp(
                // theme: theme(),
                debugShowCheckedModeBanner: false,
                initialRoute: SplashScreen.routeName,
                routes: routes,
              );
            }));
  }
}

