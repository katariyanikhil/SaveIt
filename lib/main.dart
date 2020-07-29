import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/constants/appTheme.dart';
import 'package:saveit/screens/navigationHomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await FlutterDownloader.initialize(debug: true // optional: set false to disable printing logs to console
      );
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveIt',
      theme: ThemeData.dark().copyWith(
        textTheme: AppTheme.textTheme,
        accentColor: Colors.blue,
        textSelectionColor: Colors.blue,
        textSelectionHandleColor: Colors.blue,
        platform: TargetPlatform.iOS,
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeLogo(),
    );
  }
}

class WelcomeLogo extends StatefulWidget {
  @override
  _WelcomeLogoState createState() => _WelcomeLogoState();
}

class _WelcomeLogoState extends State<WelcomeLogo> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationHomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Scaffold(
          backgroundColor: ThemeData.dark().primaryColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: screenHeightSize(650, context),
              ),
              Image.asset(
                'assets/images/appLogo.png',
                height: screenWidthSize(200, context),
                width: screenWidthSize(200, context),
              ),
              Text(
                'Save It',
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 34,
                ),
              ),
              Text(
                'All In One Download in One Click',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
