import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class InstaData {
  static Future<InstaProfile> userProfileData(String profileUrl) async {
    InstaProfile _profileParsed = InstaProfile();
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    var _document, jsonData, finalData;
    Map<String, String> _userData = Map<String, String>();
    String _dataPatternStart = "{\"config\":{\"csrf_token\"";
    String _dataPatternEnd = ",\"frontend_env\":\"prod\"}";

    try {
      if (!profileUrl.contains('https://www.instagram.com/')) {
        profileUrl = 'https://www.instagram.com/' + profileUrl;
      }
      _response = await _client.get('$profileUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;

      String invalid = '"entry_data":{"HttpErrorPage"';
      if (_temporaryData.contains(invalid)) {
        // Invaild URL
        return null;
      }

      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_dataPatternStart);
      _endInx = _temporaryData.indexOf(_dataPatternEnd) + _dataPatternEnd.length;
      _temporaryData = _temporaryData.substring(_startInx).substring(0, _endInx - 21);
      jsonData = json.decode(_temporaryData);
      finalData = jsonData['entry_data']['ProfilePage'][0]['graphql']['user'];
      _userData['profileUrl'] = 'https://www.instagram.com/' + finalData['username'].toString();
      _userData['profilePicUrl'] = finalData['profile_pic_url'].toString();
      _userData['profilePicUrlHd'] = finalData['profile_pic_url_hd'].toString();
      _userData['username'] = finalData['username'].toString();
      _userData['fullName'] = finalData['full_name'].toString();
      _userData['bio'] = finalData['biography'].toString().replaceAll('\n', '');
      _userData['postsCount'] = finalData['edge_owner_to_timeline_media']['count'].toString();
      _userData['followingsCount'] = finalData['edge_followed_by']['count'].toString();
      _userData['followersCount'] = finalData['edge_follow']['count'].toString();
      _userData['isPrivate'] = finalData['is_private'].toString();
      _userData['isVerified'] = finalData['is_verified'].toString();

      _profileParsed = InstaProfile.fromMap(_userData);
    } catch (error) {
      print('[InstaData][userProfileData][userProfileData]: $error');
    }

    return _profileParsed;
  }

  static Future<InstaProfile> postFromUrl(String postUrl) async {
    InstaProfile _profileParsed = InstaProfile();
    InstaPost _postParsed = InstaPost();
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    var _document, jsonData, finalData;
    Map<String, String> _postData = Map<String, String>();
    List<ChildPost> _childpostData = [];

    String _patternStart = "{\"config\":{\"csrf_token\"";
    String _patternEnd = ",\"frontend_env\":\"prod\"}";

    try {
      _response = await _client.get('$postUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;

      String invalid = '"entry_data":{"HttpErrorPage"';
      if (_temporaryData.contains(invalid)) {
        print('Invalid Url');
        return null;
      }

      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart);
      _endInx = _temporaryData.indexOf(_patternEnd) + _patternEnd.length;
      _temporaryData = _temporaryData.substring(_startInx).substring(0, _endInx - 21);
      jsonData = json.decode(_temporaryData);
    } catch (error) {
      print('[InstaData][postFromUrl]: $error');
    }
    if (jsonData['entry_data']['PostPage'] != null) {
      finalData = jsonData['entry_data']['PostPage'][0]['graphql']['shortcode_media'];

      _postData['childPostsCount'] = finalData['edge_media_to_caption'].length.toString();
      _postData['postUrl'] = postUrl;
      _postData['photoSmallUrl'] = finalData['display_resources'][0]['src'];
      _postData['photoMediumUrl'] = finalData['display_resources'][1]['src'];
      _postData['photoLargeUrl'] = finalData['display_resources'][2]['src'];
      _postData['description'] = finalData['edge_media_to_caption']['edges'][0]['node']['text'].toString().replaceAll('\n', ' ');

      var date = DateTime.fromMillisecondsSinceEpoch(finalData['taken_at_timestamp'] * 1000);
      var formattedDate = DateFormat.yMMMd().format(date);
      _postData['datetime'] = formattedDate.toString();
      _postData['likes'] = finalData['edge_media_preview_like']['count'].toString();
      _postData['commentsCount'] = finalData['edge_media_to_parent_comment']['count'].toString();
      _postData['videoUrl'] = finalData['video_url'].toString();
      _postData['videoViewsCount'] = finalData['video_view_count'].toString();

      //MULTIPLE POST IN ONE POST
      try {
        if (finalData['edge_sidecar_to_children'].length == 1) {
          _postData['childPostsCount'] = finalData['edge_sidecar_to_children']['edges'].length.toString();
          for (var item in finalData['edge_sidecar_to_children']['edges']) {
            _childpostData.add(
              ChildPost(
                photoSmallUrl: item['node']['display_resources'][0]['src'].toString(),
                photoMediumUrl: item['node']['display_resources'][1]['src'].toString(),
                photoLargeUrl: item['node']['display_resources'][2]['src'].toString(),
                videoUrl: item['node']['video_url'].toString(),
              ),
            );
          }
        }
      } catch (error) {
        // No Children Post
      }

      _postParsed = InstaPost.fromMap(_postData);
      _postParsed.childposts = _childpostData;

      //USER PROFILE DATA
      var userUrl = 'https://www.instagram.com/' + finalData['owner']['username'].toString();
      _profileParsed = await userProfileData(userUrl);
      _profileParsed.postData = _postParsed;
      return _profileParsed;
    }
    //PRIVATE USER INFO
    if (jsonData['entry_data']['ProfilePage'].length == 1) {
      finalData = jsonData['entry_data']['ProfilePage'][0]['graphql']['user']['username'];

      _profileParsed = await userProfileData('https://www.instagram.com/$finalData/');

      return _profileParsed;
    }
    return _profileParsed;
  }

  static Future<InstaProfile> storyFromUrl(String userUrl) async {
    InstaProfile _profileParsed = InstaProfile();
    String _temporaryData = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    var _document, jsonData;
    List<InstaStory> _storyData = [];

    _profileParsed = await InstaData.userProfileData(userUrl);
    if (_profileParsed != null) {
      if (_profileParsed.isPrivate == false) {
        String _patternStart = "{\"pageProps\":";
        String _patternEnd = ",\"__N_SSP\":tru";

        try {
          String username = userUrl.replaceAll('https://www.instagram.com/', '');
          username = username.replaceAll('https://instagram.com/', '');
          username = username.replaceAll('/', '');
          _response = await _client.get('https://storiesig.com/stories/$username');
          _document = parse(_response.body);
          _document = _document.querySelectorAll('body');
          _temporaryData = _document[0].text;

          _temporaryData = _temporaryData.trim();
          _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
          _endInx = _temporaryData.indexOf(_patternEnd);
          _temporaryData = _temporaryData.substring(_startInx, _endInx);
          jsonData = json.decode(_temporaryData);

          // print(jsonData);
          _profileParsed.storyCount = int.parse(jsonData['stories']['media_count'].toString());
          for (var item in jsonData['stories']['items']) {
            var date = DateTime.fromMillisecondsSinceEpoch(item['taken_at'] * 1000);
            _storyData.add(InstaStory(
              storyDate: date.toString(),
              storyType: item['media_type'].toString() == '1' ? 'photo' : 'video',
              storyHeight: item['original_height'].toString(),
              storyWidth: item['original_width'].toString(),
              storyThumbnail: item['image_versions2']['candidates'][0]['url'].toString(),
              downloadUrl: item['media_type'].toString() == '1' ? item['image_versions2']['candidates'][0]['url'].toString() : item['video_versions'][0]['url'].toString(),
            ));
          }
          _profileParsed.storyData = _storyData;
        } catch (error) {
          print('[InstaData][storyFromUrl]: $error');
        }
      } else {
        // Private Acc
        return _profileParsed;
      }
    } else {
      // Invaild URL
      return null;
    }
    return _profileParsed;
  }
}

class InstaProfile {
  String profileUrl = '';
  String profilePicUrl = '';
  String profilePicUrlHd = '';
  String username = '';
  String fullName = '';
  String bio = '';
  int postsCount = 0;
  int followingsCount = 0;
  int followersCount = 0;
  bool isPrivate = true;
  bool isVerified = false;
  int storyCount = 0;
  InstaPost postData;
  List<InstaStory> storyData;

  InstaProfile({this.profileUrl, this.profilePicUrl, this.profilePicUrlHd, this.username, this.fullName, this.bio, this.postsCount, this.followingsCount, this.followersCount, this.isPrivate, this.isVerified, this.postData, this.storyData});

  factory InstaProfile.fromMap(Map<String, String> map) {
    return InstaProfile(
      profileUrl: map['profileUrl'],
      profilePicUrl: map['profilePicUrl'],
      profilePicUrlHd: map['profilePicUrlHd'],
      username: map['username'],
      fullName: map['fullName'],
      bio: map['bio'],
      postsCount: int.parse(map['postsCount']),
      followingsCount: int.parse(map['followingsCount']),
      followersCount: int.parse(map['followersCount']),
      isPrivate: map['isPrivate'] == 'false' ? false : true,
      isVerified: map['isVerified'] == 'true' ? true : false,
      postData: InstaPost(),
      storyData: [],
    );
  }
}

class InstaPost {
  InstaProfile instaProfile = InstaProfile();
  String postUrl = '';
  String photoSmallUrl = '';
  String photoMediumUrl = '';
  String photoLargeUrl = '';
  String videoUrl = '';
  String description = '';
  String dateTime = '';
  List<ChildPost> childposts = [];
  int childPostsCount = 0;
  int likes = 0;
  int commentsCount = 0;
  String videoViewsCount = '0';

  InstaPost({
    this.postUrl,
    this.photoSmallUrl,
    this.photoMediumUrl,
    this.photoLargeUrl,
    this.videoUrl,
    this.description,
    this.dateTime,
    this.childposts,
    this.childPostsCount,
    this.likes,
    this.commentsCount,
    this.videoViewsCount,
  });

  factory InstaPost.fromMap(Map<String, String> map) {
    return InstaPost(
      postUrl: map['postUrl'],
      photoSmallUrl: map['photoSmallUrl'],
      photoMediumUrl: map['photoMediumUrl'],
      photoLargeUrl: map['photoLargeUrl'],
      videoUrl: map['videoUrl'] == null ? '' : map['videoUrl'],
      description: map['description'] == null ? '' : map['description'],
      dateTime: map['dateTime'],
      childposts: [],
      childPostsCount: int.parse(map['childPostsCount']),
      likes: int.parse(map['likes']),
      commentsCount: int.parse(map['commentsCount']),
      videoViewsCount: map['videoViewsCount'] == null ? '' : map['videoViewsCount'],
    );
  }
}

class ChildPost {
  String photoSmallUrl = '';
  String photoMediumUrl = '';
  String photoLargeUrl = '';
  String videoUrl = '';
  String videoViewsCount = '';

  ChildPost({
    this.photoSmallUrl,
    this.photoMediumUrl,
    this.photoLargeUrl,
    this.videoUrl,
  });
}

class InstaStory {
  String storyDate = '';
  String storyType = '';
  String storyHeight = '';
  String storyWidth = '';
  String storyThumbnail = '';
  String downloadUrl = '';

  InstaStory({
    this.storyDate,
    this.storyType,
    this.storyHeight,
    this.storyWidth,
    this.storyThumbnail,
    this.downloadUrl,
  });

  factory InstaStory.fromMap(Map<String, String> map) {
    return InstaStory(
      storyDate: map['storyDate'],
      storyType: map['storyType'],
      storyHeight: map['storyHeight'],
      storyWidth: map['storyWidth'],
      storyThumbnail: map['storyThumbnail'],
      downloadUrl: map['downloadUrl'],
    );
  }
}
