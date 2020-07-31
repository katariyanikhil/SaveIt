import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/screens/whatsappDownload/imageScreen.dart';
import 'package:saveit/screens/whatsappDownload/videoScreen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

final Directory _videoDir = Directory('/storage/emulated/0/WhatsApp/Media/.Statuses/');
final Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs/');

class WhatsappDownload extends StatefulWidget {
  @override
  _WhatsappDownloadState createState() => _WhatsappDownloadState();
}

class _WhatsappDownloadState extends State<WhatsappDownload> with TickerProviderStateMixin {
  TabController _whatsappTabController;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  _loadthumb() async {
    if (Directory("${_videoDir.path}").existsSync()) {
      var videoList = _videoDir.listSync().map((item) => item.path).where((item) => item.endsWith(".mp4")).toList(growable: false);

      for (var x in videoList) {
        var tmp = x.replaceAll(_videoDir.path.toString(), '');

        if (!File(thumbDir.path.toString() + tmp.substring(0, tmp.length - 4) + '.png').existsSync()) {
          await VideoThumbnail.thumbnailFile(
            video: x,
            thumbnailPath: thumbDir.path,
            imageFormat: ImageFormat.PNG,
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _whatsappTabController = TabController(length: 2, vsync: this);
    if (!thumbDir.existsSync()) {
      thumbDir.createSync(recursive: true);
    }
    _loadthumb();
  }

  @override
  void dispose() {
    super.dispose();
    _whatsappTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: screenAppBar("WhatsApp Downloader"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset("assets/images/whatsappLogo.png", scale: 5.0),
                ),
                Text(
                  ' WhatsApp Status\n   Dowloader',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Container(
              child: TabBar(controller: _whatsappTabController, indicatorColor: Colors.blue, labelColor: Colors.blue, unselectedLabelColor: Colors.white, labelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.0), isScrollable: false, unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12.0), tabs: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.photo_library),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('IMAGES'),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.live_tv),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('VIDEOS'),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            Container(
              height: screenHeightSize(400, context),
              child: TabBarView(
                controller: _whatsappTabController,
                children: <Widget>[
                  WAImageScreen(
                    scaffoldKey: _scaffoldKey,
                  ),
                  WAVideoScreen(
                    scaffoldKey: _scaffoldKey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
