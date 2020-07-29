package com.nikhil.saveit

import android.util.Log
import android.util.SparseArray
import androidx.annotation.NonNull
import at.huber.youtubeExtractor.VideoMeta
import at.huber.youtubeExtractor.YouTubeExtractor
import at.huber.youtubeExtractor.YtFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    private val CHANNEL: String = "videoLink"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "videoLinks") {
                        var videoLink = call.argument<String>("videoLink")
                        if (videoLink != null) {
                            var videoLinks:HashMap<String,String> = HashMap()
                            object : YouTubeExtractor(this) {
                                override fun onExtractionComplete(ytFiles: SparseArray<YtFile>?, vMeta: VideoMeta) {

                                    if (ytFiles != null) {

                                        for (i in 0 until ytFiles.size()) {
                                            var tag = ytFiles.keyAt(i)
                                            var ytFile: YtFile = ytFiles.get(tag)

                                            if (ytFile.format.height == -1 || ytFile.format.height >=144) {
                                                
                                                var title: String = vMeta.getTitle()

                                                if (ytFile.format.height == -1 || ytFile.format.height >=144){
                                                    if(ytFile.format.height == -1){
                                                        // videoLinks.put("${title} [AUDIO-${ytFile.format.audioBitrate}kbps].${ytFile.format.ext}", ytFile.url)
                                                        videoLinks.put("${title} [AUDIO-${ytFile.format.audioBitrate}kbps].mp3", ytFile.url)
                                                    }else{
                                                        var avList = listOf(17,36,18,22)
                                                        if(ytFile.format.ext != "webm"){
                                                            if(avList.contains(ytFile.format.itag)){
                                                                videoLinks.put("${title} [VIDEO ${ytFile.format.height}p].${ytFile.format.ext}",ytFile.url)
                                                            }else{
                                                            videoLinks.put("${title} [VIDEO(NO Audio) ${ytFile.format.height}p].${ytFile.format.ext}",ytFile.url)
                                                            }
                                                        }
                                                        
                                                    }

                                                }
                                            }
                                        }
                                        result.success(videoLinks)
                                    }else result.error("null", "some error occurred", null)
                                }
                            }.extract(videoLink, true, true)
                        }
                    }
                //    else if(call.method == "videoTitles"){

                //        var videoLink = call.argument<String>("videoLink")
                //        if (videoLink != null) {
                //            var videoTitles:ArrayList<String> = ArrayList()
                //            object : YouTubeExtractor(this) {
                //                override fun onExtractionComplete(ytFiles: SparseArray<YtFile>?, vMeta: VideoMeta) {
                //                    if (ytFiles != null) {

                //                        for (i in 0 until ytFiles.size()) {
                //                            var tag = ytFiles.keyAt(i)
                //                            var ytFile: YtFile = ytFiles.get(tag)


                //                            if (ytFile.format.height == -1 || ytFile.format.height >=360) {

                //                                if(ytFile.format.height == -1)
                //                                    videoTitles.add("Audio_${ytFile.format.audioBitrate}_kbit/s.${ytFile.format.ext}")
                //                                else
                //                                    videoTitles.add("${ytFile.format.height}p.${ytFile.format.ext}")

                //                                Log.d("video","Adding title")


                //                            }
                //                        }
                //                        result.success(listOf(videoTitles))
                //                    }else result.error("null", "some error occurred", null)
                //                }
                //            }.extract(videoLink, true, true)
                //        }
                //    }

                }
    }

}
