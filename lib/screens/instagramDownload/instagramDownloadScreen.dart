import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:saveit/constants/appConstant.dart';
import 'package:saveit/screens/instagramDownload/InstaData.dart';

Directory dir = Directory('/storage/emulated/0/SaveIt/Instagram');
Directory thumbDir = Directory('/storage/emulated/0/.saveit/.thumbs');

class InstagramDownload extends StatefulWidget {
  @override
  _InstagramDownloadState createState() => _InstagramDownloadState();
}

class _InstagramDownloadState extends State<InstagramDownload> with SingleTickerProviderStateMixin {
  var _igScaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _urlController = TextEditingController();
  InstaProfile _instaProfile;
  InstaPost _instaPost = InstaPost();
  List<bool> _isVideo = [false];
  bool _showData = false, _isDisabled = true, _isPost = false, _isPrivate = false, _notfirst = false;

  bool validateURL(List<String> urls) {
    Pattern pattern = r'^((http(s)?:\/\/)?((w){3}.)?instagram?(\.com)?\/|).+$';
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
      key: _igScaffoldKey,
      appBar: screenAppBar("Instagram Downloader"),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Image.asset(
                    "assets/images/instagramLogo.png",
                    scale: 5.0,
                  ),
                ),
                Text(
                  ' Instagram\n   Dowloader',
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
                          'assets/images/instagramLogo.png',
                          scale: 14.0,
                        ),
                      ),
                    ),
                    hintText: 'https://www.instagram.com/...'),
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
                    result['text'] = result['text'].toString().replaceAll(RegExp(r'\?igshid=.*'), '');
                    result['text'] = result['text'].toString().replaceAll(RegExp(r'https://instagram.com/'), '');
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _urlController.text = result['text'].toString().replaceAll(RegExp(r'\?igshid=.*'), ''),
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
                          //Check Internet Connection
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if (connectivityResult == ConnectivityResult.none) {
                            _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'No Internet'));
                            return;
                          }

                          _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Fetching Download links...'));
                          setState(() {
                            _notfirst = true;
                            _showData = false;
                            _isPrivate = false;
                          });

                          if (_urlController.text.contains('/p/') || _urlController.text.contains('/tv/') || _urlController.text.contains('/reel/')) {
                            _instaProfile = await InstaData.postFromUrl('${_urlController.text}');
                            if (_instaProfile == null) {
                              _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Invalid Url'));
                              setState(() {
                                _notfirst = false;
                              });
                            } else {
                              _instaPost = _instaProfile.postData;
                              if (_instaProfile.isPrivate == true) {
                                setState(() {
                                  _isPrivate = true;
                                });
                                _instaPost.childPostsCount = 1;
                                _instaPost.videoUrl = 'null';
                                _instaPost.photoSmallUrl = _instaProfile.profilePicUrl;
                                _instaPost.photoMediumUrl = _instaProfile.profilePicUrl;
                                _instaPost.photoLargeUrl = _instaProfile.profilePicUrlHd;
                                _instaPost.description = _instaProfile.bio;
                              } else {
                                setState(() {
                                  _isPrivate = false;
                                });
                              }

                              setState(() {
                                if (_instaPost.childPostsCount > 1) {
                                  _isVideo.clear();
                                  _instaPost.childposts.forEach((element) {
                                    element.videoUrl.length > 4 ? _isVideo.add(true) : _isVideo.add(false);
                                  });
                                } else {
                                  _isVideo.clear();
                                  _instaPost.videoUrl.length > 4 ? _isVideo.add(true) : _isVideo.add(false);
                                }
                                _showData = true;
                                _isPost = true;
                              });
                            }
                          } else {
                            // STORY
                            _instaProfile = await InstaData.storyFromUrl('${_urlController.text}');
                            if (_instaProfile == null) {
                              _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Invalid Url'));
                              setState(() {
                                _notfirst = false;
                              });
                            } else {
                              if (_instaProfile.isPrivate == true) {
                                setState(() {
                                  _isPost = true;
                                  _isPrivate = true;
                                });
                                _instaPost.childPostsCount = 1;
                                _instaPost.videoUrl = 'null';
                                _instaPost.photoSmallUrl = _instaProfile.profilePicUrl;
                                _instaPost.photoMediumUrl = _instaProfile.profilePicUrl;
                                _instaPost.photoLargeUrl = _instaProfile.profilePicUrlHd;
                                _instaPost.description = _instaProfile.bio;
                              } else {
                                setState(() {
                                  _isPost = false;
                                  _isPrivate = false;
                                  if (_instaProfile.storyCount > 0) {
                                    _isVideo.clear();
                                    for (var item in _instaProfile.storyData) {
                                      if (item.storyThumbnail == item.downloadUrl) {
                                        _isVideo.add(false);
                                      } else {
                                        _isVideo.add(true);
                                      }
                                    }
                                  }
                                });
                              }

                              setState(() {
                                _showData = true;
                              });
                            }
                          }
                        },
                      ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            _isPrivate
                ? Text(
                    'This Account is Private',
                    style: TextStyle(fontSize: 14.0),
                  )
                : Container(),
            _notfirst
                ? _showData
                    ? _isPost
                        ? Container(
                            padding: EdgeInsets.only(bottom: 30.0),
                            margin: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: screenHeightSize(350, context),
                              child: GridView.builder(
                                itemCount: _instaPost.childPostsCount,
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
                                              thumbnail: NetworkImage(_instaPost.childPostsCount > 1 ? _instaPost.childposts[index].photoMediumUrl : _instaPost.photoMediumUrl),
                                              image: NetworkImage(_instaPost.childPostsCount > 1 ? _instaPost.childposts[index].photoLargeUrl : _instaPost.photoLargeUrl),
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                          _isVideo[index]
                                              ? Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4.0),
                                                    child: Icon(Icons.videocam),
                                                  ),
                                                )
                                              : Align(),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0, left: 5.0),
                                        child: GestureDetector(
                                          child: Text(
                                            '${_instaPost.description.length > 100 ? _instaPost.description.replaceRange(100, _instaPost.description.length, '') : _instaPost.description}...',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          onTap: () async {
                                            Clipboard.setData(ClipboardData(text: _instaPost.description));
                                            _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Caption Copied'));
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: MyButton(
                                          text: 'Download',
                                          padding: EdgeInsets.all(5.0),
                                          color: Theme.of(context).accentColor,
                                          onPressed: () async {
                                            _igScaffoldKey.currentState.showSnackBar(mySnackBar(context, 'Added to Download'));
                                            String downloadUrl = _instaPost.childPostsCount == 1 ? _instaPost.videoUrl.length > 4 ? _instaPost.videoUrl : _instaPost.photoLargeUrl : _instaPost.childposts[index].videoUrl.length > 4 ? _instaPost.childposts[index].videoUrl : _instaPost.childposts[index].photoLargeUrl;
                                            String name = 'IG-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.${downloadUrl.toString().contains('jpg') ? 'jpg' : 'mp4'}';
                                            String thumbUrl = _instaPost.childPostsCount > 1 ? _instaPost.childposts[index].photoLargeUrl : _instaPost.photoLargeUrl;
                                            await FlutterDownloader.enqueue(
                                              url: thumbUrl,
                                              savedDir: thumbDir.path,
                                              fileName: name.substring(0, name.length - 3) + 'jpg',
                                              showNotification: false,
                                            );
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
                            padding: EdgeInsets.only(bottom: 30.0),
                            margin: EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: screenHeightSize(280, context),
                              child: GridView.builder(
                                itemCount: _instaProfile.storyCount,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: <Widget>[
                                      Stack(
                                        children: <Widget>[
                                          Container(
                                            height: screenWidthSize(165, context),
                                            width: screenWidthSize(125, context),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.rectangle,
                                              color: Theme.of(context).scaffoldBackgroundColor,
                                            ),
                                            child: ProgressiveImage(
                                              placeholder: AssetImage('assets/images/placeholder_video.gif'),
                                              thumbnail: NetworkImage(_instaProfile.storyData[index].storyThumbnail),
                                              image: NetworkImage(_instaProfile.storyData[index].storyThumbnail),
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          _isVideo[index]
                                              ? Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4.0),
                                                    child: Icon(Icons.videocam),
                                                  ),
                                                )
                                              : Align(),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: MyButton(
                                          text: 'Download',
                                          padding: EdgeInsets.all(5.0),
                                          color: Theme.of(context).accentColor,
                                          onPressed: () async {
                                            String downloadUrl = _instaProfile.storyData[index].downloadUrl;
                                            String name = 'IG-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}.${downloadUrl.toString().contains('jpg') ? 'jpg' : 'mp4'}';
                                            String thumbUrl = _instaProfile.storyData[index].storyThumbnail;
                                            _isVideo[index] == true
                                                ? await FlutterDownloader.enqueue(
                                                    url: thumbUrl,
                                                    savedDir: thumbDir.path,
                                                    fileName: name.substring(0, name.length - 3) + 'jpg',
                                                    showNotification: false,
                                                  )
                                                : print('');
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
                                  );
                                },
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 10.0,
                                  childAspectRatio: 0.5,
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
