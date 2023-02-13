import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver{
  var viewPlayerController;
  late MethodChannel _channel;
  bool isNormalScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _channel =  MethodChannel('bms_video_player');
    _channel.setMethodCallHandler(_handleMethod);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if(Platform.isIOS) {
      _channel.invokeMethod('pauseVideo', 'pauseVideo');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        this.viewPlayerController.resumeVideo();
        break;
      case AppLifecycleState.paused:
        this.viewPlayerController.pauseVideo();
        break;
      default:
        break;
    }
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'fullScreen':
        isNormalScreen = false;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        setState(() {

        });
        break;
      case 'normalScreen':
        isNormalScreen = true;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: [SystemUiOverlay.bottom,SystemUiOverlay.top]);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        setState(() {

        });
        break;
    }
  }

  void onViewPlayerCreated(viewPlayerController) {
    this.viewPlayerController = viewPlayerController;
  }

  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    var width = 400.0;
    var height = isNormalScreen?400.0:MediaQuery.of(context).size.height;

    BmsVideoPlayer videoPlayer =  BmsVideoPlayer(
        onCreated: onViewPlayerCreated,
        x: x,
        y: y,
        width: width,
        height: height, key: null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Ads Demo"),
        centerTitle: true,
      ),
      body:
      ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: videoPlayer,
            width: width,
            height: height,
            color: Colors.black,
          );
        },
      ),
    );
  }
}

class _VideoPlayerState extends State<BmsVideoPlayer> {

  String viewType = 'NativeUI';
  var viewPlayerController;



  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: nativeView(),
    );
  }

  nativeView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL":"https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
        },

        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
          "videoURL":"https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.onCreated == null) {
      return;
    }

    widget.onCreated( BmsVideoPlayerController.init(id));
  }
}

typedef void BmsVideoPlayerCreatedCallback(BmsVideoPlayerController controller);

class BmsVideoPlayerController {

  late MethodChannel _channel;

  BmsVideoPlayerController.init(int id) {
    _channel =   MethodChannel('bms_video_player');
  }

  Future<void> loadUrl(String url) async {
    assert(url != null);
    return _channel.invokeMethod('loadUrl', url);
  }

  Future<void> pauseVideo() async {
    return _channel.invokeMethod('pauseVideo', 'pauseVideo');
  }

  Future<void> resumeVideo() async {
    return _channel.invokeMethod('resumeVideo', 'resumeVideo');
  }
}


class BmsVideoPlayer extends StatefulWidget {

  final BmsVideoPlayerCreatedCallback onCreated;
  final x;
  final y;
  final width;
  final height;

  BmsVideoPlayer({
     Key? key,
    required this.onCreated,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();

}
