import 'package:flutter/services.dart';
import 'package:saveit/constants/appTheme.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatefulWidget {
  final AnimationController iconAnimationController;
  final DrawerIndex screenIndex;
  final Function(DrawerIndex) callBackIndex;
  HomeDrawer(
      {Key key,
      this.screenIndex,
      this.iconAnimationController,
      this.callBackIndex})
      : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList> drawerList;
  @override
  void initState() {
    setdDrawerListArray();
    super.initState();
  }

  void setdDrawerListArray() {
    drawerList = [
      DrawerList(
        index: DrawerIndex.Home,
        labelName: 'Home',
        icon: new Icon(Icons.home),
      ),
      DrawerList(
        index: DrawerIndex.Gallery,
        labelName: 'Galley',
        icon: Icon(Icons.wallpaper),
      ),
      DrawerList(
        index: DrawerIndex.ShareApp,
        labelName: 'Share the App',
        icon: Icon(Icons.share),
      ),
      DrawerList(
        index: DrawerIndex.RateApp,
        labelName: 'Rate App',
        icon: Icon(Icons.star),
      ),
      DrawerList(
        index: DrawerIndex.DonateUs,
        labelName: 'Donate Us',
        icon: Icon(Icons.monetization_on),
      ),
      DrawerList(
        index: DrawerIndex.About,
        labelName: 'About Us',
        icon: Icon(Icons.info),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: widget.iconAnimationController,
                        builder: (BuildContext context, Widget child) {
                          return new ScaleTransition(
                            scale: new AlwaysStoppedAnimation(1.0 -
                                (widget.iconAnimationController.value) * 0.2),
                            child: RotationTransition(
                              turns: new AlwaysStoppedAnimation(
                                  Tween(begin: 0.0, end: 24.0)
                                          .animate(CurvedAnimation(
                                              parent: widget
                                                  .iconAnimationController,
                                              curve: Curves.fastOutSlowIn))
                                          .value /
                                      360),
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: AppTheme.grey.withOpacity(0.1),
                                        blurRadius: 4),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60.0)),
                                  child: Image.asset("assets/images/appLogo.png"),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          "Save It",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Divider(
              height: 1,
              color: AppTheme.grey.withOpacity(0.5),
            ),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(0.0),
                itemCount: drawerList.length,
                itemBuilder: (context, index) {
                  return inkwell(drawerList[index]);
                },
              ),
            ),
            Divider(
              height: 1,
              color: AppTheme.grey.withOpacity(0.6),
            ),
            Column(
              children: <Widget>[
                ListTile(
                  title: new Text(
                    "Exit",
                    style: new TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  trailing: new Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                  ),
                  onTap: () {
                    SystemNavigator.pop();
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationtoScreen(listData.index);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 6.0,
                    height: 46.0,
                    // decoration: BoxDecoration(
                    //   color: widget.screenIndex == listData.index
                    //       ? Colors.blue
                    //       : Colors.transparent,
                    //   borderRadius: new BorderRadius.only(
                    //     topLeft: Radius.circular(0),
                    //     topRight: Radius.circular(16),
                    //     bottomLeft: Radius.circular(0),
                    //     bottomRight: Radius.circular(16),
                    //   ),
                    // ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? Container(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index
                                  ? Colors.blue
                                  : Theme.of(context).iconTheme.color),
                        )
                      : new Icon(listData.icon.icon,
                          color: widget.screenIndex == listData.index
                              ? Colors.blue
                              : Theme.of(context).iconTheme.color),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  new Text(
                    listData.labelName,
                    style: new TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index
                          ? Colors.blue
                          : Theme.of(context).iconTheme.color,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return new Transform(
                        transform: new Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 32) *
                                (1.0 -
                                    widget.iconAnimationController.value -
                                    1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * 0.75 - 32,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  void navigationtoScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex(indexScreen);
  }
}

enum DrawerIndex {
  Home,
  Gallery,
  ShareApp,
  RateApp,
  DonateUs,
  About,
}

class DrawerList {
  String labelName;
  Icon icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex index;

  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });
}
