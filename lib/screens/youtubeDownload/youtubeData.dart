import 'dart:convert';
import 'package:html/parser.dart';
import 'package:http/http.dart';

class YoutubeData {
  static YoutubeChannel _youtubeChannel = YoutubeChannel();

  static Future<YoutubeChannel> channelInfoFromUrl(String url) async {
    String _temporaryData = '', _patternStart = '', _patternEnd = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    var _document, jsonData;

    try {
      _response = await _client.get('$url');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();
      _temporaryData = _temporaryData.replaceAll('\n', '');

      _patternStart = 'window["ytInitialData"] = ';
      _patternEnd = ';    window["ytInitialPlayerResponse"]';
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      jsonData = json.decode(_temporaryData.toString());

      _postData['channelId'] = jsonData['header']['c4TabbedHeaderRenderer']['channelId'].toString();
      _postData['channelUrl'] = jsonData['metadata']['channelMetadataRenderer']['channelUrl'].toString();
      _postData['channelName'] = jsonData['header']['c4TabbedHeaderRenderer']['title'].toString();
      _postData['channelDescription'] = jsonData['metadata']['channelMetadataRenderer']['description'].toString().replaceAll('\n', ' ');
      _postData['keywords'] = '';
      for (var item in jsonData['microformat']['microformatDataRenderer']['tags']) {
        _postData['keywords'] = _postData['keywords'] + item.toString();
      }
      _postData['keywords'] = _postData['keywords'].substring(0, _postData['keywords'].length - 1);
      _postData['profilePictureUrl'] = jsonData['metadata']['channelMetadataRenderer']['avatar']['thumbnails'][0]['url'].toString();
      _postData['bannerPictureUrl'] = jsonData['header']['c4TabbedHeaderRenderer']['banner']['thumbnails'][5]['url'].toString();
      _postData['subsCount'] = jsonData['header']['c4TabbedHeaderRenderer']['subscriberCountText']['runs'][0]['text'].toString().replaceAll(' subscribers', '');
      _postData['videosCount'] = jsonData['contents']['twoColumnBrowseResultsRenderer']['secondaryContents']['browseSecondaryContentsRenderer']['contents'][0]['verticalChannelSectionRenderer']['items'][0]['miniChannelRenderer']['videoCountText']['runs'][0]['text'].toString().replaceAll(' videos', '');
      _postData['isVerified'] = jsonData['contents']['twoColumnBrowseResultsRenderer']['secondaryContents']['browseSecondaryContentsRenderer']['contents'][0]['verticalChannelSectionRenderer']['items'][0]['miniChannelRenderer']['ownerBadges'][0]['metadataBadgeRenderer']['tooltip'].toString();
      _postData['isVerified'] = _postData['isVerified'] == 'Verified' ? 'true' : 'false';

      _youtubeChannel = YoutubeChannel.fromMap(_postData);
    } catch (error) {
      print('[YoutubeData][channelInfoFromUrl]: $error');
    }
    return _youtubeChannel;
  }

  static Future<YoutubeChannel> videoFromUrl(String url) async {
    String _temporaryData = '', _patternStart = '', _patternEnd = '';
    int _startInx = 0, _endInx = 1;
    Client _client = Client();
    Response _response;
    Map<String, String> _postData = Map<String, String>();
    List<VideoInfo> video = [];
    List<AudioInfo> audio = [];
    var _document, jsonData;

    try {
      _response = await _client.get('$url');
      _document = parse(_response.body);
      _document = _document.querySelectorAll('body');
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();

      _patternStart = '"streamingData":';
      _patternEnd = ',"playbackTracking"';
      _temporaryData = _temporaryData.replaceAll('\\\\u0026', '&');
      _temporaryData = _temporaryData.replaceAll('\\\/', '/');
      _temporaryData = _temporaryData.replaceAll('\\\"', '"');
      _temporaryData = _temporaryData.replaceAll('\\\\', '');
      _temporaryData = _temporaryData.replaceAll('codecs="', 'codecs=');
      _temporaryData = _temporaryData.replaceAll('""', '"');
      _startInx = _temporaryData.indexOf(_patternStart);
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = '{' + _temporaryData.substring(_startInx, _endInx) + '}';
      jsonData = json.decode(_temporaryData.toString());
      jsonData = jsonData['streamingData'];

      //DATA FOUND
      for (var item in jsonData['formats']) {
        video.add(VideoInfo(
          videoItag: item['itag'],
          videoUrl: item['url'].toString(),
          videoMimeType: item['mimeType'].toString(),
          videoWidth: item['width'].toString(),
          videoHeight: item['height'].toString(),
          videoQuality: item['qualityLabel'].toString(),
          hasAudio: true,
        ));
      }
      List qual = [];
      for (int x = 0; x < jsonData['adaptiveFormats'].length - 4; x++) {
        if (qual.contains(jsonData['adaptiveFormats'][x]['qualityLabel'].toString())) {
        } else {
          qual.add(jsonData['adaptiveFormats'][x]['qualityLabel'].toString());
          video.add(VideoInfo(
            videoItag: jsonData['adaptiveFormats'][x]['itag'],
            videoUrl: jsonData['adaptiveFormats'][x]['url'].toString(),
            videoMimeType: jsonData['adaptiveFormats'][x]['mimeType'].toString(),
            videoWidth: jsonData['adaptiveFormats'][x]['width'].toString(),
            videoHeight: jsonData['adaptiveFormats'][x]['height'].toString(),
            videoQuality: jsonData['adaptiveFormats'][x]['qualityLabel'].toString(),
            hasAudio: false,
          ));
        }
      }
      for (int x = jsonData['adaptiveFormats'].length - 4; x < jsonData['adaptiveFormats'].length; x++) {
        int tag = jsonData['adaptiveFormats'][x]['itag'];
        int bit;
        if (tag == 140) {
          bit = 128;
        } else if (tag == 249) {
          bit = 48;
        } else if (tag == 250) {
          bit = 64;
        } else if (tag == 251) {
          bit = 160;
        }
        audio.add(AudioInfo(
          audioItag: jsonData['adaptiveFormats'][x]['itag'],
          audioUrl: jsonData['adaptiveFormats'][x]['url'].toString(),
          audioMimeType: jsonData['adaptiveFormats'][x]['mimeType'].toString(),
          audioBitrate: bit,
        ));
      }

      _patternStart = '"playerMicroformatRenderer":';
      _patternEnd = ',"uploadDate":';
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd) + _patternEnd.length + 13;
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      jsonData = json.decode(_temporaryData.toString());

      _postData['videolink'] = url;
      _postData['title'] = jsonData['title']['simpleText'].toString();
      _postData['description'] = jsonData['description']['simpleText'].toString().replaceAll('"', '');
      _postData['description'] = _postData['description'].replaceAll('\n', '  ');
      _postData['thumbnail'] = jsonData['thumbnail']['thumbnails'][0]['url'];
      _postData['ownerUrl'] = jsonData['ownerProfileUrl'].toString();
      _postData['channelName'] = jsonData['ownerChannelName'].toString();
      _postData['category'] = jsonData['category'].toString();
      _postData['date'] = jsonData['uploadDate'].toString();
      _postData['length'] = jsonData['lengthSeconds'].toString();
      _postData['viewsCount'] = jsonData['viewCount'].toString();

      _patternStart = ',"topLevelButtons":';
      _patternEnd = ',{"buttonRenderer"';
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx) + ']';
      jsonData = json.decode(_temporaryData.toString());

      _postData['likesCount'] = jsonData[0]['toggleButtonRenderer']['defaultText']['accessibility']['accessibilityData']['label'].toString().replaceAll(' likes', '');
      _postData['likesCount'] = _postData['likesCount'].replaceAll(',', '');
      _postData['dislikesCount'] = jsonData[1]['toggleButtonRenderer']['defaultText']['accessibility']['accessibilityData']['label'].toString().replaceAll(' dislikes', '');
      _postData['dislikesCount'] = _postData['dislikesCount'].replaceAll(',', '');

      _patternStart = ',"isPrivate":';
      _patternEnd = ',"isUnpluggedCorpus"';
      _temporaryData = _document[0].text;
      _temporaryData = _temporaryData.trim();
      _startInx = _temporaryData.indexOf(_patternStart) + _patternStart.length;
      _endInx = _temporaryData.indexOf(_patternEnd);
      _temporaryData = _temporaryData.substring(_startInx, _endInx);
      _postData['isPrivate'] = _temporaryData.toString();

      _youtubeChannel = await channelInfoFromUrl(_postData['ownerUrl']);
      _youtubeChannel.videoData = YoutubeVideo.fromMap(_postData);
      _youtubeChannel.videoData.videoInfo = video;
      _youtubeChannel.videoData.audioInfo = audio;
    } catch (error) {
      print('[YoutubeData][videoFromUrl]: $error');
    }

    return _youtubeChannel;
  }
}

class YoutubeChannel {
  String channelId = '';
  String channelUrl = '';
  String channelName = '';
  String channelDescription = '';
  String keywords = '';
  String profilePictureUrl = '';
  String bannerPictureUrl = '';
  String joinedDate = '';
  String subsCount = '';
  int videosCount = 0;
  int totalViewsCount = 0;
  bool isVerified = false;
  YoutubeVideo videoData;

  YoutubeChannel({
    this.channelId,
    this.channelUrl,
    this.channelName,
    this.channelDescription,
    this.keywords,
    this.profilePictureUrl,
    this.bannerPictureUrl,
    this.joinedDate,
    this.subsCount,
    this.videosCount,
    this.totalViewsCount,
    this.isVerified,
    this.videoData,
  });

  factory YoutubeChannel.fromMap(Map<String, String> map) {
    return YoutubeChannel(
      channelId: map['channelId'].toString() == null ? '' : map['channelId'],
      channelUrl: map['channelUrl'].toString() == null ? '' : map['channelUrl'],
      channelName: map['channelName'].toString() == null ? '' : map['channelName'],
      channelDescription: map['channelDescription'].toString() == null ? '' : map['channelDescription'],
      keywords: map['keywords'].toString() == null ? '' : map['keywords'],
      profilePictureUrl: map['profilePictureUrl'].toString() == null ? '' : map['profilePictureUrl'],
      bannerPictureUrl: map['bannerPictureUrl'].toString() == null ? '' : map['bannerPictureUrl'],
      joinedDate: map['joinedDate'].toString() == null ? '' : map['joinedDate'],
      // subsCount: map['subsCount'].toString()==null?'':map['subsCount'],
      videosCount: int.parse(map['videosCount'].toString() == null ? '' : map['videosCount']),
      // totalViewsCount: int.parse(map['totalViewsCount'].toString()==null?'':map['totalViewsCount'].toString()),
      isVerified: map['isVerified'].toString() == 'false' ? false : true,
    );
  }
}

class YoutubeVideo {
  String videolink = '';
  String title = '';
  String description = '';
  String thumbnail = '';
  String ownerUrl = '';
  String channelName = '';
  String category = '';
  String date = '';
  bool isPrivate = true;
  int length = 0;
  int viewsCount = 0;
  int likesCount = 0;
  int dislikesCount = 0;
  // int commentsCount = 0;
  List<VideoInfo> videoInfo;
  List<AudioInfo> audioInfo;

  YoutubeVideo({
    this.videolink,
    this.title,
    this.description,
    this.thumbnail,
    this.ownerUrl,
    this.channelName,
    this.category,
    this.date,
    this.length,
    this.isPrivate,
    this.viewsCount,
    this.likesCount,
    this.dislikesCount,
    // this.commentsCount,
    this.videoInfo,
    this.audioInfo,
  });

  factory YoutubeVideo.fromMap(Map<String, String> map) {
    return YoutubeVideo(
      videolink: map['videolink'].toString(),
      title: map['title'].toString(),
      description: map['description'].toString(),
      thumbnail: map['thumbnail'].toString(),
      ownerUrl: map['ownerUrl'].toString(),
      channelName: map['channelName'].toString(),
      category: map['category'].toString(),
      date: map['date'].toString(),
      isPrivate: map['isPrivate'] == 'false' ? false : true,
      length: int.parse(map['length'].toString()),
      viewsCount: int.parse(map['viewsCount'].toString()),
      likesCount: int.parse(map['likesCount'].toString()),
      dislikesCount: int.parse(map['likesCount'].toString()),
      // commentsCount: int.parse(map['commentsCount'].toString()),
      videoInfo: [],
      audioInfo: [],
    );
  }
}

class VideoInfo {
  int videoItag = 0;
  String videoUrl = '';
  String videoMimeType = '';
  String videoWidth = '';
  String videoHeight = '';
  String videoQuality = '';
  bool hasAudio = false;

  VideoInfo({
    this.videoItag,
    this.videoUrl,
    this.videoMimeType,
    this.videoWidth,
    this.videoHeight,
    this.videoQuality,
    this.hasAudio,
  });

  factory VideoInfo.fromMap(Map<String, String> map) {
    return VideoInfo(
      videoItag: int.parse(map['videoItag'].toString()),
      videoUrl: map['videoUrl'].toString(),
      videoWidth: map['videoWidth'].toString(),
      videoHeight: map['videoHeight'].toString(),
      videoQuality: map['videoQuality'].toString(),
      videoMimeType: map['videoMimeType'].toString(),
    );
  }
}

class AudioInfo {
  int audioItag = 0;
  String audioUrl = '';
  String audioMimeType = '';
  int audioBitrate = 0;

  AudioInfo({
    this.audioItag,
    this.audioUrl,
    this.audioMimeType,
    this.audioBitrate,
  });

  factory AudioInfo.fromMap(Map<String, String> map) {
    return AudioInfo(
      audioItag: int.parse(map['audioItag'].toString()),
      audioUrl: map['audioUrl'].toString(),
      audioMimeType: map['audioMimeType'].toString(),
      audioBitrate: int.parse(['audioBitrate'].toString()),
    );
  }
}
