import 'dart:io';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:saveit/constants/appConstant.dart';

final Directory _videoDir = Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');
Directory dir = Directory('/storage/emulated/0/SaveIt/WhatsApp');
Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs/');

class WAVideoScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  WAVideoScreen({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _WAVideoScreenState createState() => _WAVideoScreenState(scaffoldKey: scaffoldKey);
}

class _WAVideoScreenState extends State<WAVideoScreen> {
  GlobalKey<ScaffoldState> scaffoldKey;
  String tmpThumbnail;
  _WAVideoScreenState({Key key, this.scaffoldKey});

  Future<void> _downloadFile(String filePath) async {
    File originalVideoFile = File(filePath);
    String filename = 'WA-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.mp4';
    String path = dir.path;
    String newFileName = "$path/$filename";

    File thumbFile = File(tmpThumbnail);
    String thumbname = filename.replaceAll('.mp4', '.jpg');
    String newThumbName = '${thumbDir.path}/$thumbname';

    await thumbFile.copy(newThumbName);

    await originalVideoFile.copy(newFileName);
  }

  @override
  void initState() {
    super.initState();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    if (!thumbDir.existsSync()) {
      thumbDir.createSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_videoDir.path}").existsSync()) {
      return Center(
        child: Text(
          "Install WhatsApp\nYour Friend's Status will be available here.",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else {
      var videoList = _videoDir.listSync().map((item) => item.path).where((item) => item.endsWith(".mp4")).toList(growable: false);

      if (videoList != null) {
        if (videoList.length > 0) {
          return Container(
            padding: EdgeInsets.only(bottom: 30.0),
            margin: EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                String videoPath = videoList[index];
                String thumbnailPath = thumbDir.path + '/' + videoPath.substring(45, videoPath.length - 4) + '.png';
                return Column(
                  children: <Widget>[
                    Container(
                      height: screenHeightSize(150, context),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Stack(
                        children: <Widget>[
                          ProgressiveImage(
                            placeholder: AssetImage('assets/images/placeholder_video.gif'),
                            thumbnail: FileImage(File(thumbnailPath)),
                            image: FileImage(File(thumbnailPath)),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.videocam),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: MyButton(
                        text: 'Download',
                        padding: EdgeInsets.all(5.0),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          tmpThumbnail = thumbnailPath;
                          _downloadFile(videoPath);
                          scaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Video Stored at SaveIt/WhatsApp'));
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 0.5,
              ),
            ),
          );
        } else {
          return Center(
            child: Text(
              "Sorry, No Videos Found.",
              style: TextStyle(fontSize: 18.0),
            ),
          );
        }
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }
}
