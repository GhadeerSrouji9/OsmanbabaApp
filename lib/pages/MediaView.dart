

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaView extends StatefulWidget {
  final String mediaLinkArg;
  final int indexArg;
  MediaView(this.mediaLinkArg, this.indexArg);

  @override
  State<StatefulWidget> createState() {
    return _StateMediaView();
  }

}

class _StateMediaView extends State<MediaView>{
  VideoPlayerController _controller;

  String mediaLink;
  int index;

  @override
  void initState() {
    if(widget.mediaLinkArg != null && widget.indexArg != null){
      mediaLink = widget.mediaLinkArg;
      index = widget.indexArg;
    }
    super.initState();

    _controller = VideoPlayerController.network(mediaLink)
//    _controller = VideoPlayerControllers.network("https://88.225.215.42:8083/Files/AdsVideo/269fc40c-48cb-4030-823f-c18475094cc0/269fc40c-48cb-4030-823f-c18475094cc0.mp4")
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
              child: index != 0 ? Container(
                margin: EdgeInsets.symmetric(horizontal: 64.0),
                child: Image.network(
                  mediaLink
                ),
              ): Container(
                child: _controller.value.isInitialized ? GestureDetector(
                  onTap: (){
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ) : Container(
                  child: CircularProgressIndicator(),
                ),
              ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}