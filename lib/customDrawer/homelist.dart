import 'package:flutter/widgets.dart';
import 'package:saveit/screens/facebookDownload/facebookDownloadScreen.dart';
import 'package:saveit/screens/instagramDownload/instagramDownloadScreen.dart';
import 'package:saveit/screens/tiktokDownload/tiktokDownloadScreen.dart';
import 'package:saveit/screens/whatsappDownload/whatsappDownloadScreen.dart';
import 'package:saveit/screens/youtubeDownload/youtubeDownloadScreen.dart';

class HomeList {
  String title;
  Widget navigateScreen;
  String imagePath;

  HomeList({
    this.title,
    this.navigateScreen,
    this.imagePath = '',
  });

  static List<HomeList> homeList = [
    HomeList(
      title: 'Facebook',
      imagePath: 'assets/images/facebookLogo.png',
      navigateScreen: FacebookDownload(),
    ),
    HomeList(
      title: 'WhatsApp',
      imagePath: 'assets/images/whatsappLogo.png',
      navigateScreen: WhatsappDownload(),
    ),
    HomeList(
      title: 'Instagram',
      imagePath: 'assets/images/instagramLogo.png',
      navigateScreen: InstagramDownload(),
    ),
    HomeList(
      title: 'Youtube',
      imagePath: 'assets/images/youtubeLogo.png',
      navigateScreen: YoutubeDownload(),
    ),
    HomeList(
      title: 'Tiktok',
      imagePath: 'assets/images/tiktokLogo.png',
      navigateScreen: TiktokDownload(),
    ),
  ];
}

