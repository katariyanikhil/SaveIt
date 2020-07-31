import 'dart:convert';
import 'dart:io';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class TiktokData {
  static TiktokProfile _profileParsed = TiktokProfile();
  static TiktokMusic _musicParsed = TiktokMusic();

  static Future<TiktokProfile> profileFromUrl(String profileUrl) async {
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document, jsonData;

    String _patternStart = '"userInfo":';
    String _patternEnd = ',"userData"';

    try {
      _response = await _client.get('$profileUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;

      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      jsonData = json.decode(_temporaryData);

      _postData['profileUrl'] = 'https://www.tiktok.com/@' + jsonData['user']['uniqueId'].toString();
      _postData['profilePicUrl'] = jsonData['user']['avatarThumb'].toString();
      _postData['profilePicUrlHd'] = jsonData['user']['avatarMedium'].toString();
      _postData['userName'] = jsonData['user']['uniqueId'].toString();
      _postData['displayName'] = jsonData['user']['nickname'].toString();
      _postData['bio'] = jsonData['user']['signature'].toString().replaceAll('\n', ' ');
      _postData['videosCount'] = jsonData['stats']['videoCount'].toString();
      _postData['likesCount'] = jsonData['stats']['heartCount'].toString();
      _postData['followingsCount'] = jsonData['stats']['followingCount'].toString();
      _postData['followersCount'] = jsonData['stats']['followerCount'].toString();
      _postData['isPrivate'] = jsonData['user']['secret'].toString();
      _postData['isVerified'] = jsonData['user']['verified'].toString();

      _profileParsed = TiktokProfile.fromMap(_postData);
    } catch (error) {
      print('[InstaData][storyFromUrl]: $error');
    }

    return _profileParsed;
  }

  static Future<TiktokProfile> postFromUrl(String postUrl) async {
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document, jsonData;

    String _patternStart = ',"pageProps":';
    String _patternEnd = ',"pathname":';

    try {
      _response = await _client.get('$postUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;
      Directory dir = Directory('/storage/emulated/0/');
      File f = File(dir.path + 'ntt.txt');
      f.writeAsString(_temporaryData);

      String block = 'Govt. of India decided to block 59 apps, including TikTok';
      if (_temporaryData.contains(block)) {
        return null;
      }

      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      jsonData = json.decode(_temporaryData);

      _postData['videoUrl'] = postUrl;
      _postData['videoId'] = jsonData['videoData']['itemInfos']['id'].toString();
      _postData['thumbnailUrl'] = jsonData['videoData']['itemInfos']['covers'][0].toString();
      _postData['videoWatermarkUrl'] = jsonData['videoData']['itemInfos']['video']['urls'][0].toString();
      _postData['description'] = jsonData['videoData']['itemInfos']['text'].toString();
      _postData['dateTime'] = DateTime.fromMillisecondsSinceEpoch(int.parse(jsonData['videoData']['itemInfos']['createTime'].toString()) * 1000).toString();

      String noUseTags = jsonData['videoData']['authorInfos']['uniqueId'].toString() + ', ' + jsonData['videoData']['authorInfos']['nickName'].toString();
      noUseTags = noUseTags + ', TikTok, ティックトック, tik tok, tick tock, tic tok, tic toc, tictok, тик ток, ticktock,';
      _postData['hashtags'] = jsonData['metaParams']['keywords'].toString().replaceAll(noUseTags, '');

      _postData['likes'] = jsonData['videoData']['itemInfos']['diggCount'].toString();
      _postData['commentsCount'] = jsonData['videoData']['itemInfos']['commentCount'].toString();
      _postData['videoViewsCount'] = jsonData['videoData']['itemInfos']['playCount'].toString();
      _postData['sharesCount'] = jsonData['videoData']['itemInfos']['shareCount'].toString();

      var profileUrl = 'https://www.tiktok.com/@' + jsonData['videoData']['authorInfos']['uniqueId'].toString();
      _profileParsed = await profileFromUrl(profileUrl);
      _profileParsed.videoData = TiktokVideo.fromMap(_postData);
      var mname = jsonData['videoData']['musicInfos']['musicName'].toString().replaceAll(' ', '-');
      _profileParsed.videoData.videoMusic = await musicFromUrl('https://www.tiktok.com/music/' + mname + '-' + jsonData['videoData']['musicInfos']['musicId'].toString());
    } catch (error) {
      print('[InstaData][videoFromUrl]: $error');
    }

    return _profileParsed;
  }

  static Future<TiktokMusic> musicFromUrl(String musicUrl) async {
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document, jsonData;

    String _patternStart = '"pageProps":';
    String _patternEnd = ',"pathname"';

    try {
      _response = await _client.get('$musicUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');

      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      jsonData = json.decode(_temporaryData);

      jsonData = jsonData['musicData'];
      _postData['musicId'] = jsonData['musicId'].toString();
      _postData['musicTitle'] = jsonData['musicName'].toString();
      _postData['musicAuthor'] = jsonData['authorName'].toString();
      _postData['musicCover'] = jsonData['coversMedium'][0].toString();
      _postData['musicUrl'] = jsonData['playUrl']['UrlList'][0].toString();
      _postData['postCount'] = jsonData['posts'].toString();

      _musicParsed = TiktokMusic.fromMap(_postData);
    } catch (error) {
      print('[InstaData][musicFromUrl]: $error');
    }

    return _musicParsed;
  }
}

class TiktokProfile {
  String profileUrl = '';
  String profilePicUrl = '';
  String profilePicUrlHd = '';
  String userName = '';
  String displayName = '';
  String bio = '';
  int videosCount = 0;
  int likesCount = 0;
  int followingsCount = 0;
  int followersCount = 0;
  bool isPrivate = true;
  bool isVerified = false;
  TiktokVideo videoData;

  TiktokProfile({
    this.profileUrl,
    this.profilePicUrl,
    this.profilePicUrlHd,
    this.userName,
    this.displayName,
    this.bio,
    this.videosCount,
    this.likesCount,
    this.followingsCount,
    this.followersCount,
    this.isPrivate,
    this.isVerified,
    this.videoData,
  });

  factory TiktokProfile.fromMap(Map<String, String> map) {
    return TiktokProfile(
      profileUrl: map['profileUrl'],
      profilePicUrl: map['profilePicUrl'],
      profilePicUrlHd: map['profilePicUrlHd'],
      userName: map['userName'],
      displayName: map['displayName'],
      bio: map['bio'] == null ? '' : map['bio'],
      videosCount: int.parse(map['videosCount'] == null ? '' : map['videosCount']),
      likesCount: int.parse(map['likesCount']),
      followingsCount: int.parse(map['followingsCount']),
      followersCount: int.parse(map['followersCount']),
      isPrivate: map['isPrivate'] == 'false' ? false : true,
      isVerified: map['isVerified'] == 'false' ? false : true,
    );
  }
}

class TiktokVideo {
  String videoUrl = '';
  String videoId = '';
  String thumbnailUrl;
  String videoWatermarkUrl = '';
  String videoNoWatermarkUrl = '';
  String description = '';
  String dateTime = '';
  List<String> hashtags = [];
  int likes = 0;
  int commentsCount = 0;
  int videoViewsCount = 0;
  int sharesCount = 0;
  TiktokMusic videoMusic;

  TiktokVideo({
    this.videoUrl,
    this.videoId,
    this.thumbnailUrl,
    this.videoWatermarkUrl,
    this.videoNoWatermarkUrl,
    this.description,
    this.dateTime,
    this.hashtags,
    this.likes,
    this.commentsCount,
    this.videoViewsCount,
    this.sharesCount,
    this.videoMusic,
  });

  factory TiktokVideo.fromMap(Map<String, String> map) {
    return TiktokVideo(
      videoUrl: map['videoUrl'] == null ? '' : map['videoUrl'],
      videoId: map['videoId'] == null ? '' : map['videoId'],
      thumbnailUrl: map['thumbnailUrl'] == null ? '' : map['thumbnailUrl'],
      videoNoWatermarkUrl: map['videoNoWatermarkUrl'] == null ? '' : map['videoNoWatermarkUrl'],
      videoWatermarkUrl: map['videoWatermarkUrl'],
      description: map['description'] == null ? '' : map['description'],
      dateTime: map['dateTime'] == null ? '' : map['dateTime'],
      hashtags: map['hashtags'].split(','),
      likes: int.parse(map['likes'] == null ? '0' : map['likes']),
      commentsCount: int.parse(map['commentsCount'] == null ? '0' : map['commentsCount']),
      videoViewsCount: int.parse(map['videoViewsCount'] == null ? '0' : map['videoViewsCount']),
      sharesCount: int.parse(map['sharesCount'] == null ? '0' : map['sharesCount']),
    );
  }
}

class TiktokMusic {
  String musicId = '';
  String musicTitle = '';
  String musicAuthor = '';
  String musicCover = '';
  String musicUrl = '';
  int postCount = 0;

  TiktokMusic({
    this.musicId,
    this.musicTitle,
    this.musicAuthor,
    this.musicCover,
    this.musicUrl,
    this.postCount,
  });

  factory TiktokMusic.fromMap(Map<String, String> map) {
    return TiktokMusic(
      musicId: map['musicId'] == null ? '' : map['musicId'],
      musicTitle: map['musicTitle'] == null ? '' : map['musicTitle'],
      musicAuthor: map['musicAuthor'] == null ? '' : map['musicAuthor'],
      musicCover: map['musicCover'] == null ? '' : map['musicCover'],
      musicUrl: map['musicUrl'] == null ? '' : map['musicUrl'],
      postCount: int.parse(map['postCount'] == null ? '' : map['postCount']),
    );
  }
}
