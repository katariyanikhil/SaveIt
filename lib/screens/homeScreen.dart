import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/customDrawer/homelist.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  PermissionStatus status;
  int denyCnt = 0;
  List<HomeList> homeList = HomeList.homeList;

  void _getPermission() async {
    status = await Permission.storage.request();

    if (status == PermissionStatus.permanentlyDenied) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Storage Permission Requried'),
            content: Text('Enable Storage Permission from App Setting'),
            actions: <Widget>[
              FlatButton(
                child: Text('Open Setting'),
                onPressed: () async {
                  openAppSettings();
                  exit(0);
                },
              )
            ],
          );
        },
      );
    } else {
      while (!status.isGranted) {
        if (denyCnt > 20) {
          exit(0);
        }
        status = await Permission.storage.request();
        denyCnt++;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  Future<bool> getData() async {
    await Future.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox();
          } else {
            return Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  appBar(),
                  SizedBox(
                    height: 25.0,
                  ),
                  Expanded(
                    child: FutureBuilder(
                      future: getData(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        } else {
                          return GridView(
                            padding: EdgeInsets.only(top: 0, left: 12, right: 12),
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: List.generate(
                              homeList.length,
                              (index) {
                                return HomeListView(
                                  listData: homeList[index],
                                  callBack: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => homeList[index].navigateScreen,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 5.0,
                              childAspectRatio: 1.0,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget appBar() {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8, left: 8),
            child: Container(
              width: AppBar().preferredSize.height - 8,
              height: AppBar().preferredSize.height - 8,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Save It",
                  style: new TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeListView extends StatelessWidget {
  final HomeList listData;
  final VoidCallback callBack;
  final AnimationController animationController;
  final Animation animation;

  const HomeListView({Key key, this.listData, this.callBack, this.animationController, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: screenWidthSize(80, context),
          height: screenWidthSize(80, context),
          child: CircleAvatar(
            backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
            child: ClipOval(
              child: Stack(
                alignment: AlignmentDirectional.center,
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    listData.imagePath,
                    fit: BoxFit.cover,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      onTap: () {
                        callBack();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            listData.title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
