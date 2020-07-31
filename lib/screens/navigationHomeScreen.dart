import 'package:rate_my_app/rate_my_app.dart';
import 'package:saveit/customDrawer/homeDrawer.dart';
import 'package:saveit/customDrawer/drawerUserController.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homeScreen.dart';
import 'galleryScreen.dart';
import 'package:flutter/material.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  AnimationController sliderAnimationController;

  RateMyApp _rateApp = RateMyApp(
    preferencesPrefix: 'rateApp_',
    minDays: 3,
    minLaunches: 5,
    remindDays: 2,
    remindLaunches: 4,
    // googlePlayIdentifier: '',
    // appStoreIdentifier: '',
  );

  Future<void> _lauchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        enableJavaScript: true,
        forceWebView: false,
        forceSafariVC: false,
      );
    } else {
      print('Can\'t Lauch url');
    }
  }

  @override
  void initState() {
    drawerIndex = DrawerIndex.Home;
    screenView = MyHomePage();
    super.initState();
    _rateApp.init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            animationController: (AnimationController animationController) {
              sliderAnimationController = animationController;
            },
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.Home) {
        setState(() {
          screenView = MyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.Gallery) {
        setState(() {
          screenView = GalleryScreen();
        });
      } else if (drawerIndex == DrawerIndex.ShareApp) {
        setState(() {
          Share.share('Download Stories,Videos,Status and much more in One Click using SaveIt App.\n Checkout the Link below also share it with your Friends.\n https://bit.ly/39y0mar');
          screenView = MyHomePage();
          drawerIndex = DrawerIndex.Home;
        });
      } else if (drawerIndex == DrawerIndex.RateApp) {
        _rateApp.showStarRateDialog(
          context,
          title: 'Enjoying using SaveIt',
          message: 'If you like this app, please rate it !\nIt really helps us and it shouldn\'t take you more than one minute.',
          dialogStyle: DialogStyle(
            titleAlign: TextAlign.center,
            messagePadding: EdgeInsets.only(bottom: 20.0),
          ),
          actionsBuilder: (context, stars) {
            return [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('LATER'),
              ),
              FlatButton(
                onPressed: () {
                  if (stars != 0.0) {
                    _rateApp.save().then((value) => Navigator.pop(context));
                  } else {}
                },
                child: Text('OK'),
              ),
            ];
          },
          starRatingOptions: StarRatingOptions(),
        );

        setState(() {
          drawerIndex = DrawerIndex.Home;
          screenView = MyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.DonateUs) {
        String _donateUrl = 'https://www.buymeacoffee.com/katariyanikhil';
        _lauchUrl(_donateUrl);
        setState(() {
          drawerIndex = DrawerIndex.Home;
          screenView = MyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.About) {
        String _donateUrl = 'https://www.github.com/katariyanikhil';
        _lauchUrl(_donateUrl);
        setState(() {
          drawerIndex = DrawerIndex.Home;
          screenView = MyHomePage();
        });
      } else {
        //do in your way......
      }
    }
  }
}
