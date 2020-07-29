import 'package:flutter/material.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/screens/facebookDownload/galleryScreen.dart';
import 'package:saveit/screens/instagramDownload/galleryScreen.dart';
import 'package:saveit/screens/tiktokDownload/galleryScreen.dart';
import 'package:saveit/screens/whatsappDownload/galleryScreen.dart';
import 'package:saveit/screens/youtubeDownload/galleryScreen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> with TickerProviderStateMixin {
  TabController _galleryTabController;

  @override
  void initState() {
    super.initState();
    _galleryTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _galleryTabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: screenAppBar('App Gallery'),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              child: TabBar(
                controller: _galleryTabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.white,
                isScrollable: true,
                tabs: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('WhatsApp'),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('Youtube'),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('Instagram'),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('Facebook'),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text('TikTok'),
                    ),
                  ),
                  // Tab(
                  //   icon: Icon(Icons.photo_library),
                  //   text: 'IMAGES',
                  // ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: screenHeightSize(650, context),
              child: TabBarView(
                controller: _galleryTabController,
                children: <Widget>[
                  WhatsappGallery(),
                  YoutubeGallery(),
                  InstagramGallery(),
                  FacebookGallery(),
                  TiktokGallery(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
