import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer_demo/domain/bloc/controller.dart';
import 'package:video_viewer_demo/ui/settings_menu/settings_menu_item.dart';
import 'package:video_viewer_demo/ui/video_core/video_core.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({
    super.key,
    // required this.fixedLandscape,
  });

  // final bool fixedLandscape;

  @override
  FullScreenPageState createState() => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage> {
  // late Timer _systemResetTimer;

  @override
  void initState() {
    // _systemResetTimer = Timer.periodic(
    //   Duration(milliseconds: 300),
    //       (_) {
    //         // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [],);
    //         // setState(() {});
    //       },
    // );

    // if (widget.fixedLandscape) _setLandscapeFixed();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [],);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    // _systemResetTimer.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values,);
    super.dispose();
  }

  // Future<void> _setLandscapeFixed() async {
  //   await SystemChrome.setPreferredOrientations([
  //     ...[DeviceOrientation.landscapeLeft],
  //     ...[DeviceOrientation.landscapeRight]
  //   ]);
  //
  //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [],);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          // _systemResetTimer.cancel();
          await Provider.of<VideoViewerController>(context, listen: false).openOrCloseFullscreen();
          return false;
        },
        child: Center(
          child: VideoViewerCore(),
        ),
      ),
    );
  }
}
