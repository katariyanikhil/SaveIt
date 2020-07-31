import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveit/constants/appConstant.dart';

final Directory _photoDir = Directory('/storage/emulated/0/WhatsApp/Media/.Statuses');
Directory dir = Directory('/storage/emulated/0/SaveIt/WhatsApp');

class WAImageScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  WAImageScreen({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _WAImageScreenState createState() => _WAImageScreenState(scaffoldKey: scaffoldKey);
}

class _WAImageScreenState extends State<WAImageScreen> {
  GlobalKey<ScaffoldState> scaffoldKey;
  _WAImageScreenState({Key key, this.scaffoldKey});

  Future<void> _downloadFile(String filePath) async {
    File originalVideoFile = File(filePath);
    String filename = 'WA-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.jpg';
    String path = dir.path;
    String newFileName = "$path/$filename";

    await originalVideoFile.copy(newFileName);
  }

  @override
  void initState() {
    super.initState();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Directory("${_photoDir.path}").existsSync()) {
      return Center(
        child: Text(
          "Install WhatsApp Now\nYour Friend's Status Will Be Available Here",
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else {
      var imageList = _photoDir.listSync().map((item) => item.path).where((item) => item.endsWith(".jpg")).toList(growable: false);
      if (imageList.length > 0) {
        return Container(
          padding: EdgeInsets.only(bottom: 30.0),
          margin: EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              String imgPath = imageList[index];
              return Column(
                children: <Widget>[
                  Container(
                    height: screenHeightSize(150, context),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Image.file(
                      File(imgPath),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: MyButton(
                      text: 'Download',
                      padding: EdgeInsets.all(5.0),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        _downloadFile(imgPath);
                        scaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Image Stored at SaveIt/WhatsApp'));
                      },
                    ),
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
        return Scaffold(
          body: Center(
            child: new Container(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Text(
                  'Sorry, No Image Found!',
                  style: TextStyle(fontSize: 18.0),
                )),
          ),
        );
      }
    }
  }
}
