import 'package:html/parser.dart';
import 'package:http/http.dart';

class FacebookData {
  static FacebookProfile _profileParsed = FacebookProfile();

  static Future<FacebookProfile> postFromUrl(String profileUrl) async {
    String _temporaryData = '', _patternStart = '', _patternEnd = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document;

    try {
      _response = await _client.get('$profileUrl');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();

      _patternStart = 'permalinkURL:"';
      _patternEnd = '/"}],1],';
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd) + 1;
      _postData['postUrl'] = _temporaryData.substring(_startInx, _endInx);

      _patternStart = ',sd_src:';
      _patternEnd = '",hd_tag:';
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length + 1;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _postData['videoSdUrl'] = _temporaryData.substring(_startInx, _endInx);

      _patternStart = ',hd_src:"';
      _patternEnd = '",sd_src:';
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _postData['videoHdUrl'] = _temporaryData.substring(_startInx, _endInx) != 'null' ? _temporaryData.substring(_startInx, _endInx) : _postData['videoSdUrl'];

      if (!_temporaryData.contains('audio:[]')) {
        _patternStart = 'audio:[{url:"';
        _patternEnd = '",start:0,end:';
        _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
        _endInx = _temporaryData.substring(_startInx).indexOf(_patternEnd) + _startInx;
        _postData['videoMp3Url'] = _temporaryData.substring(_startInx, _endInx);
      } else {
        _postData['videoMp3Url'] = '';
      }

      // _patternStart = ',i18n_reaction_count:"';
      // _patternEnd = '",important_reactors:';
      // _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      // _endInx = _temporaryData.indexOf(_patternEnd);
      // _postData['likes'] = _temporaryData.substring(_startInx,_endInx);

      // _patternStart = ',i18n_comment_count:"';
      // _patternEnd = '",url:"';
      // _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      // _endInx = _temporaryData.indexOf(_patternEnd);
      // _postData['commentsCount'] = _temporaryData.substring(_startInx,_endInx);

      // _patternStart = ',i18n_share_count:"';
      // _patternEnd = '",share_count:';
      // _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      // _endInx = _temporaryData.indexOf(_patternEnd);
      // _postData['sharesCount'] = _temporaryData.substring(_startInx,_endInx);

      _profileParsed.postData = FacebookPost.fromMap(_postData);
    } catch (error) {
      print('[InstaData][storyFromUrl]: $error');
    }

    return _profileParsed;
  }
}

class FacebookProfile {
  FacebookPost postData;

  FacebookProfile({
    this.postData,
  });
}

class FacebookPost {
  String postUrl = '';
  String thumbnailUrl = '';
  String videoSdUrl = '';
  String videoHdUrl = '';
  String videoMp3Url = '';
  String description = '';
  String dateTime = '';
  int likes = 0;
  int commentsCount = 0;
  int sharesCount = 0;
  int videoViewsCount = 0;

  FacebookPost({
    this.postUrl,
    this.thumbnailUrl,
    this.videoSdUrl,
    this.videoHdUrl,
    this.videoMp3Url,
    this.description,
    this.dateTime,
    this.likes,
    this.commentsCount,
    this.sharesCount,
    this.videoViewsCount,
  });

  factory FacebookPost.fromMap(Map<String, String> map) {
    return FacebookPost(
      postUrl: map['postUrl'] == null ? '' : map['postUrl'],
      thumbnailUrl: map['thumbnailUrl'] == null ? '' : map['thumbnailUrl'],
      videoSdUrl: map['videoSdUrl'],
      videoHdUrl: map['videoHdUrl'],
      videoMp3Url: map['videoMp3Url'],
      description: map['description'] == null ? '' : map['description'],
      dateTime: map['dateTime'] == null ? '' : map['dateTime'],
      likes: int.parse(map['likes'] == null ? '0' : map['likes']),
      commentsCount: int.parse(map['commentsCount'] == null ? '0' : map['commentsCount']),
      sharesCount: int.parse(map['sharesCount'] == null ? '0' : map['sharesCount']),
      videoViewsCount: int.parse(map['videoViewsCount'] == null ? '0' : map['videoViewsCount']),
    );
  }
}
