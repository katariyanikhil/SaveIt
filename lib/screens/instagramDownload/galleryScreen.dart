import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saveit/constants/appConstant.dart';

Directory dir = Directory('/storage/emulated/0/SaveIt/Instagram');
Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs');

class InstagramGallery extends StatefulWidget {
  @override
  _InstagramGalleryState createState() => _InstagramGalleryState();
}

class _InstagramGalleryState extends State<InstagramGallery> {
  List<bool> _isImage = [];

  void _checkType() {
    for (var item in dir.listSync()) {
      if (item.toString().endsWith(".jpg'")) {
        _isImage.add(true);
      } else {
        _isImage.add(false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (dir.existsSync()) {
      _checkType();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!dir.existsSync()) {
      return Center(
        child: Text(
          'Sorry, No Downloads Found!',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    } else {
      var fileList = dir.listSync();
      if (fileList.length > 0) {
        return Container(
          padding: EdgeInsets.only(bottom: 150.0),
          margin: EdgeInsets.only(left: 8.0, right: 8.0),
          child: GridView.builder(
            itemCount: fileList.length,
            itemBuilder: (context, index) {
              File file = fileList[index];
              if (_isImage[index] == false) {
                String thumb = fileList[index].toString().replaceAll('File: \'/storage/emulated/0/SaveIt/Instagram/', '');
                thumb = thumb.substring(0, thumb.length - 4) + 'jpg';
                var path = thumbDir.path + '/' + thumb;
                file = File(path);
              }
              return Column(
                children: <Widget>[
                  _isImage[index]
                      ? Container(
                          height: screenWidthSize(120, context),
                          width: screenWidthSize(120, context),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Image.file(
                            file,
                            fit: BoxFit.fitWidth,
                          ),
                        )
                      : Stack(
                          children: <Widget>[
                            Container(
                              height: screenWidthSize(120, context),
                              width: screenWidthSize(120, context),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).primaryColor,
                              ),
                              child: Image.file(
                                file,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(Icons.videocam),
                              ),
                            ),
                          ],
                        )
                ],
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 1.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 0.9,
            ),
          ),
        );
      } else {
        return Scaffold(
          body: Center(
            child: new Container(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Text(
                  'Sorry, No Downloads Found!',
                  style: TextStyle(fontSize: 18.0),
                )),
          ),
        );
      }
    }
  }
}
