import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/screens/youtubeDownload/youtubeData.dart';

Directory dir = Directory('/storage/emulated/0/SaveIt/Youtube');
Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs');

class YoutubeDownload extends StatefulWidget {
  @override
  _YoutubeDownloadState createState() => _YoutubeDownloadState();
}

class _YoutubeDownloadState extends State<YoutubeDownload> with TickerProviderStateMixin {
  var _ytScaffoldKey = GlobalKey<ScaffoldState>();
  YoutubeChannel _ytChannel;
  TextEditingController _urlController = TextEditingController();
  bool _isDisabled = true, _showData = false, _notfirst = false, _isPrivate = false, _hasAudio = false;

  void _download(downloadUrl, name) async {
    await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: dir.path,
      fileName: name,
      showNotification: true,
      openFileFromNotification: true,
    );
  }

  void _getList(String type, YoutubeVideo data) async {
    String details = '';
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: screenHeightSize(225, context),
            child: ListView.builder(
                itemCount: type == 'audio' ? data.audioInfo.length : data.videoInfo.length,
                itemBuilder: (context, index) {
                  details = type == 'audio' ? data.audioInfo[index].audioBitrate.toString() + ' kbps' : data.videoInfo[index].videoQuality.toString() + '${data.videoInfo[index].hasAudio ? '' : '[ONLY VIDEO]'}';
                  return ListTile(
                    onTap: () async {
                      String url = type == 'audio' ? data.audioInfo[index].audioUrl.toString() : data.videoInfo[index].videoUrl.toString();
                      // _downloadDialog(context, url, data.title + ' $details');
                      String info = type == 'audio' ? data.audioInfo[index].audioBitrate.toString() + ' kbps' : data.videoInfo[index].videoQuality.toString() + '${data.videoInfo[index].hasAudio ? '' : '[ONLY VIDEO]'}';
                      String filename = data.title + ' - $info' + '.${type == 'audio' ? 'mp3' : 'mp4'}';
                      _download(url, filename);
                      Navigator.of(context).pop();
                    },
                    title: Text(data.title + ' - $details'),
                  );
                }),
          );
        });
  }

  bool validateURL(List<String> urls) {
    Pattern pattern = r'^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(\.com)?\/.+$';
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
      key: _ytScaffoldKey,
      appBar: screenAppBar("Youtube Downloader"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    "assets/images/youtubeLogo.png",
                    scale: 5.0,
                  ),
                ),
                Text(
                  ' Youtube\n   Dowloader',
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
                          'assets/images/youtubeLogo.png',
                          scale: 14.0,
                        ),
                      ),
                    ),
                    hintText: 'https://www.youtube.com/watch?v=...'),
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
                            _ytScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'No Internet'));
                            return;
                          }
                          setState(() {
                            _notfirst = true;
                            _showData = false;
                          });
                          _ytChannel = await YoutubeData.videoFromUrl('${_urlController.text}');
                          if (_ytChannel.videoData.videoInfo[0].videoUrl.length == 4) {
                            _ytScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Check your Url and Try Again!..'));
                            setState(() {
                              _notfirst = false;
                            });
                            return;
                          }
                          if (_ytChannel.videoData.audioInfo.length == 0) {
                            setState(() {
                              _hasAudio = false;
                            });
                          } else {
                            setState(() {
                              _hasAudio = true;
                            });
                          }
                          setState(() {
                            _showData = true;
                          });
                          // _getDownloadLink();
                        },
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            _isPrivate
                ? Text(
                    'This Video is Private',
                    style: TextStyle(fontSize: 14.0),
                  )
                : Container(),
            _notfirst
                ? _showData
                    ? Container(
                        padding: EdgeInsets.only(bottom: 30.0),
                        margin: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: screenHeightSize(375, context),
                          child: GridView.builder(
                            itemCount: 1,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              String _postDescription = _ytChannel.videoData.title;
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
                                          placeholder: AssetImage('assets/images/placeholder_video.gif'),
                                          thumbnail: NetworkImage(_ytChannel.videoData.thumbnail),
                                          image: NetworkImage(_ytChannel.videoData.thumbnail),
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
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0, left: 5.0),
                                    child: GestureDetector(
                                      child: Text(
                                        '${_postDescription.length > 100 ? _postDescription.replaceRange(100, _postDescription.length, '') : _postDescription}...',
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                      onTap: () async {
                                        Clipboard.setData(ClipboardData(text: _postDescription));
                                        _ytScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Caption Copied'));
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: MyButton(
                                      text: 'Download Thumbnail',
                                      padding: EdgeInsets.all(5.0),
                                      color: Theme.of(context).accentColor,
                                      // onPressed: _isDown
                                      //     ? null
                                      //     : () async {
                                      //         var _downloadUrl = _ytChannel.videoData.thumbnail;
                                      //         _downloadDialog(context, _downloadUrl, _ytChannel.videoData.title);
                                      //       },
                                      onPressed: () async {
                                        _ytScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Added to Download'));
                                        String downloadUrl = _ytChannel.videoData.thumbnail;
                                        String name = 'YT-Thumbnail-${_ytChannel.videoData.title}.png';
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
                                                  _getList('audio', _ytChannel.videoData);
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
                                            String downloadUrl = _ytChannel.videoData.thumbnail;
                                            String name = '${_ytChannel.videoData.title}.png';
                                            //save video thumbnail
                                            await FlutterDownloader.enqueue(
                                              url: downloadUrl,
                                              savedDir: thumbDir.path,
                                              fileName: name,
                                              showNotification: false,
                                            );
                                            _getList('video', _ytChannel.videoData);
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
