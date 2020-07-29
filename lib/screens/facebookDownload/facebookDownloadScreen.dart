import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/screens/facebookDownload/facebookData.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs');
Directory dir = Directory('/storage/emulated/0/SaveIt/Facebook');

class FacebookDownload extends StatefulWidget {
  @override
  _FacebookDownloadState createState() => _FacebookDownloadState();
}

class _FacebookDownloadState extends State<FacebookDownload> {
  var _fbScaffoldKey = GlobalKey<ScaffoldState>();
  FacebookProfile _fbProfile;
  TextEditingController _urlController = TextEditingController();
  bool _isDisabled = true, _showData = false, _hasAudio = true, _notfirst = false;
  String _postThumbnail = '';
  var thumb;

  Future<String> _loadthumb(String videoUrl) async {
    thumb = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: thumbDir.path,
      imageFormat: ImageFormat.PNG,
    );
    var rep = thumb.toString().substring(thumb.toString().indexOf('ThumbFiles/') + 'ThumbFiles/'.length, thumb.toString().indexOf('.mp4'));
    File thumbname = File(thumb.toString());
    thumbname.rename(thumbDir.path + '$rep.png');

    print(thumbDir.path + '$rep.png');
    return (thumbDir.path + '$rep.png');
  }

  bool validateURL(List<String> urls) {
    // Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?facebook?(\.com)?\/(watch\/\?v=.+|.+\/videos\/.+)$';
    Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?facebook?(\.com)?\/.+$';
    RegExp regex = new RegExp(pattern);

    for (var url in urls) {
      if (!regex.hasMatch(url)) {
        return false;
      }
    }
    return true;
  }

  void getButton(String url) {
    if (validateURL([url])) {
      setState(() {
        _isDisabled = false;
      });
    } else {
      setState(() {
        _isDisabled = true;
      });
    }
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
    return Scaffold(
      key: _fbScaffoldKey,
      appBar: screenAppBar("Facebook Downloader"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    "assets/images/facebookLogo.png",
                    scale: 5.0,
                  ),
                ),
                Text(
                  ' Facebook\n   Dowloader',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                keyboardType: TextInputType.text,
                controller: _urlController,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                    prefixIcon: InkWell(
                      child: Container(
                        child: Image.asset(
                          'assets/images/facebookLogo.png',
                          scale: 14.0,
                        ),
                      ),
                    ),
                    hintText: 'https://www.facebook.com/...'),
                onChanged: (value) {
                  getButton(value);
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MyButton(
                  text: 'PASTE',
                  onPressed: () async {
                    Map<String, dynamic> result = await SystemChannels.platform.invokeMethod('Clipboard.getData');
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _urlController.text = result['text'].toString(),
                    );
                    setState(() {
                      getButton(result['text'].toString());
                    });
                  },
                ),
                _isDisabled
                    ? MyButton(
                        text: 'Download',
                        onPressed: null,
                      )
                    : MyButton(
                        text: 'Download',
                        onPressed: () async {
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if (connectivityResult == ConnectivityResult.none) {
                            _fbScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'No Internet'));
                            return;
                          }
                          setState(() {
                            _notfirst = true;
                            _showData = false;
                          });
                          _fbProfile = await FacebookData.postFromUrl('${_urlController.text}');
                          if (_fbProfile.postData.videoMp3Url == '') {
                            setState(() {
                              _hasAudio = false;
                            });
                          } else {
                            setState(() {
                              _hasAudio = true;
                            });
                          }
                          _postThumbnail = await _loadthumb(_fbProfile.postData.videoHdUrl.toString());

                          setState(() {
                            _showData = true;
                          });
                        },
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            _notfirst
                ? _showData
                    ? Container(
                        padding: EdgeInsets.only(bottom: 30.0),
                        margin: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: screenHeightSize(350, context),
                          child: GridView.builder(
                            itemCount: 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  Stack(
                                    children: <Widget>[
                                      Container(
                                        height: screenHeightSize(200, context),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                        ),
                                        child: ProgressiveImage(
                                          placeholder: AssetImage('assets/images/placeholder_image.png'),
                                          thumbnail: FileImage(File(_postThumbnail)),
                                          image: FileImage(File(_postThumbnail)),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.fitHeight,
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
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: MyButton(
                                          text: 'Download Audio',
                                          padding: EdgeInsets.all(5.0),
                                          color: Theme.of(context).accentColor,
                                          onPressed: _hasAudio
                                              ? () async {
                                                  _fbScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Added to Download'));
                                                  String downloadUrl = _fbProfile.postData.videoSdUrl;
                                                  String name = 'FB-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}(Audio).mp3';

                                                  await FlutterDownloader.enqueue(
                                                    url: downloadUrl,
                                                    savedDir: dir.path,
                                                    fileName: name,
                                                    showNotification: true,
                                                    openFileFromNotification: true,
                                                  );
                                                }
                                              : null,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: MyButton(
                                          text: 'Download Video',
                                          padding: EdgeInsets.all(5.0),
                                          color: Theme.of(context).accentColor,
                                          onPressed: () async {
                                            _fbScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Added to Download'));
                                            String downloadUrl = _fbProfile.postData.videoHdUrl;
                                            String name = 'FB-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.mp4';

                                            File thumbFile = File(_postThumbnail);
                                            String thumbname = name.substring(0, name.length - 3) + 'jpg';
                                            String newThumbName = '${thumbDir.path}/$thumbname';

                                            await thumbFile.copy(newThumbName);

                                            await FlutterDownloader.enqueue(
                                              url: downloadUrl,
                                              savedDir: dir.path,
                                              fileName: name,
                                              showNotification: true,
                                              openFileFromNotification: true,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 5.0,
                              crossAxisSpacing: 10.0,
                              childAspectRatio: 1,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                : Container(),
          ],
        ),
      ),
    );
  }
}
