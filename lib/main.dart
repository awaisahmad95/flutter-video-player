import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_viewer_demo/video_viewer.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

late SharedPreferences prefs;

late List<VideoContent> m3u8VideoContent;

class Media {
  const Media({
    required this.thumbnail,
    required this.title,
    required this.episodes,
  });

  final String thumbnail;
  final String title;
  final List<Episode> episodes;
}

class Episode {
  const Episode({
    required this.thumbnail,
    required this.title,
    required this.episodeSources,
  });

  final String thumbnail;
  final String title;
  final List<EpisodeSource> episodeSources;
}

class EpisodeSource {
  const EpisodeSource({required this.quality, required this.url});

  final String quality;
  final String url;
}

const Media media = Media(
  thumbnail: "https://cdn.bongo-solutions.com/919f93a7-400e-4149-a70d-204beb589074/content/bb73a100-b8cd-4d0c-82a8-d2cb147b5ac7/bf7975fc-6581-4110-984e-00eb0358f31e.jpg",
  title: "Big Buck Bunny",
  episodes: [
    Episode(
      thumbnail: "https://cdn.bongo-solutions.com/919f93a7-400e-4149-a70d-204beb589074/content/bb73a100-b8cd-4d0c-82a8-d2cb147b5ac7/bf7975fc-6581-4110-984e-00eb0358f31e.jpg",
      title: 'Bunny',
      episodeSources: [
        // Source(quality: '240p', url: 'https://d2cv1vlhdw3yo8.cloudfront.net/j61zg9%2Ffile%2Fe67010fb8628bcce4be8b8dde6c99e4d_c9d08d54b77482ded5b9130b137ecdc1.mp4?response-content-disposition=inline%3Bfilename%3D%22e67010fb8628bcce4be8b8dde6c99e4d_c9d08d54b77482ded5b9130b137ecdc1.mp4%22%3B&response-content-type=video%2Fmp4&Expires=1754568177&Signature=frLi~aJ8NEfgurnnV9GAXzxEaVzdgiwT8VuTYYi14djJ6ykJDQIlj5~4epchm-IpgqUlcvoBwtBwDWKVr2togpmgKI9Jv1Uy94hqNl9rp-ICDXcmFbSEJ4P3xwuFWyi9T8BNc9RDKZcvm8NSABkww~51U5pnNnZ8sU5Jv9V1hYraO29wdtgErsUI-0LWPm7BBj2lW6fc--3CuDj3RuwYR~6i64VSBBX5joWNcAfQrceObrcJipaCbrDtvJ2KCNfee32gfpMzg0bGcGtWzs2THt6KB3KmayEzZtfLqRvb7Q5eYOmpJPhGQRubJHCWc9Ve0kC0K1ydYredff0Iy9emCg__&Key-Pair-Id=APKAJT5WQLLEOADKLHBQ'),
        // Source(quality: '320p', url: 'https://djfxe6plvdhbj.cloudfront.net/y4j0h9%2Ffile%2F6347e938fdef5031321ca0e279e126d8_e3434eacc62ec8a3c3a5a2485f927ba0.mp4?response-content-disposition=inline%3Bfilename%3D%226347e938fdef5031321ca0e279e126d8_e3434eacc62ec8a3c3a5a2485f927ba0.mp4%22%3B&response-content-type=video%2Fmp4&Expires=1754394604&Signature=UhbwDsGBgHgP8soDA6RjwYuu5L1N0wsHP4WmlLRuV6mfmoIsJ5AtfM6rFqLLoi4uuOm~AOsbCsQffwa0vjn6a~XWYziqS50KUWTgf5L~XQkBoKItfS~xMV2~rem1ASnheMIYumi9V09bWi2q9jQYkMrM6XkKO7pneI1IlCClPs96DCpWTHJ4QSBTxOzIeqlqo5X20~6liP0K91Zz4PHgUAl6J6Wkn~tFtR5i2h4Dp8MQhbp78Gb2C6T~mJorBT7kYInKqXxK0NvUREXDlH36SmyOcXqv0WEOH44GAgp49Bur-TDyCbwVFrypWImIJNx5upc0lrlKuEHE-wH9Yqnv8g__&Key-Pair-Id=APKAJT5WQLLEOADKLHBQ'),
        // Source(quality: '480p', url: 'https://d27xfwajjnh0ta.cloudfront.net/l0lvg9%2Ffile%2Fdc02ceab7b4bfb17ff715c5d3424df17_f5d72a7e4155ef255cd26d8c2c2d6a0b.mp4?response-content-disposition=inline%3Bfilename%3D%22dc02ceab7b4bfb17ff715c5d3424df17_f5d72a7e4155ef255cd26d8c2c2d6a0b.mp4%22%3B&response-content-type=video%2Fmp4&Expires=1754394634&Signature=ZPWLx5vxVxQJyScdRIZstXUwbKWEzGxueDlnIieMctntmC1eoiwzYYSJA3F1FMNyY4LcALGcG8tU2gAEPyAvTDAMNq3zWeRx0cebXwpDMa-MG95gPv8zjhUEhZAbtAYpQaJCn9PxNn2FRpSQESy~DoRk14Kx3waUYzMXKIDcCZINfMVJW7IW5V~0ZRrFl2brr7NwtiFRYmTNESNoHFmpEtF1SkrSeTZfczn5VKqCT0KNAmiai4zfM73OyVtc9X7irNjAY0GlzpZF99Jrwt82wHP~Agtr~NVnuwQ~IpgWHmI0sE1E9pzocP8x02jC-9fGtxaZ0lPN8P5db2tIdaleHg__&Key-Pair-Id=APKAJT5WQLLEOADKLHBQ'),
        // Source(quality: '720p', url: 'https://drlcj9gmcmmx1.cloudfront.net/l1jxg9%2Ffile%2F18e2f8aaf8c4cb24a3bc4a18b9ab1943_81f91bb665079bc6a25383d774fa69b6.mp4?response-content-disposition=inline%3Bfilename%3D%2218e2f8aaf8c4cb24a3bc4a18b9ab1943_81f91bb665079bc6a25383d774fa69b6.mp4%22%3B&response-content-type=video%2Fmp4&Expires=1754505631&Signature=Rq8Suobokgjq-4Ou0emG5j8m5jGvrBiADLGcap1tk55iEt~T9296SsfshuCYGd75iM2sZ~QKJHf03lcMcAaqYv4VwcZlE-rXnPQMTGnut4O8y-M4ei8UgekWXG1A~xrrovXo-RNBTj4ZQM6OeOloIFyHNvrMsheZoxMBziwI95XMsL-5covjEBYhDWnwm8ODubvQCitH~BfvNwqObG9uFhql7IW12P4yXBqXNQfe3ITElZUC0dlJ8-rxDLNtKeRVl2xx-Hgco2Ex940OHbR0KnLWQ3UZIYAZCyfUlZ1k~L5nqR2hM~VGrCDOFTx-7IaAjTOs1UEgHzaaoL1TgDgLaQ__&Key-Pair-Id=APKAJT5WQLLEOADKLHBQ'),
        EpisodeSource(quality: 'original', url: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',),
        // EpisodeSource(quality: 'original_1', url: 'https://1a-1791.com/video/fww1/f8/s8/2/o/P/4/8/oP48y.gaa.tar?r_file=chunklist.m3u8&r_type=application%2Fvnd.apple.mpegurl&r_range=2326772224-2326860504',),
        // EpisodeSource(quality: 'original_2', url: 'https://1a-1791.com/video/fww1/de/s8/2/0/q/A/9/0qA9y.aaa.mp4',),
      ],
    ),
    Episode(
      thumbnail: "https://i1.sndcdn.com/artworks-000005010194-jwzy1c-t500x500.jpg",
      title: 'Elephant',
      episodeSources: [
        EpisodeSource(quality: 'original', url: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',),
      ],
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  prefs = await SharedPreferences.getInstance();

  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://sample.vodobox.net/skate_phantom_flex_4k/skate_phantom_flex_4k.m3u8',);
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://playertest.longtailvideo.com/adaptive/wowzaid3/playlist.m3u8');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://cdn-fms.rbs.com.br/vod/hls_sample1_manifest.m3u8'); // faulty URL
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://nasatv-lh.akamaihd.net/i/NASA_101@319270/index_1000_av-p.m3u8?sd=10&rebase=on');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://content.jwplatform.com/manifests/vM7nH0Kl.m3u8');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://walterebert.com/playground/video/hls/sintel-trailer.m3u8');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8');
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'https://devimages.apple.com.edgekey.net/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8');

  // makki tv links
  // m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'https://cdn.videas.fr/v-medias/s5/hlsv1/50/e2/50e2625e-6292-4a7e-8322-ed7bb4c4fb87/720p.m3u8');
  m3u8VideoContent = await VideoSource.fromM3u8PlaylistUrl(m3u8: 'https://rumble.com/hls-vod/6v4eie/playlist.m3u8');

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Viewer Example',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VideoViewer1(media: media)),
                ),
                child: Text('Video Viewer 1'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => VideoViewer2(media: media)),
                ),
                child: Text('Video Viewer 2'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoViewer1 extends StatefulWidget {
  const VideoViewer1({required this.media, super.key});

  final Media media;

  @override
  VideoViewer1State createState() => VideoViewer1State();
}

class VideoViewer1State extends State<VideoViewer1> {
  // final VideoViewerController controller = VideoViewerController();

  late Episode initialEpisode;

  @override
  void initState() {
    initialEpisode = widget.media.episodes.first;
    VideoViewer.episodeTitle =initialEpisode.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            VideoViewer(
              // controller: controller,
              // autoPlay: true,
              // videoContentList: VideoSource.fromNetworkVideoSources(episodeSources: initialEpisode.episodeSources,),
              videoContentList: m3u8VideoContent,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('index: $index'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoViewer2 extends StatefulWidget {
  const VideoViewer2({required this.media, super.key});

  final Media media;

  @override
  State<VideoViewer2> createState() => _VideoViewer2State();
}

class _VideoViewer2State extends State<VideoViewer2> {
  // final VideoViewerController _controller = VideoViewerController();

  @override
  void initState() {
    VideoViewer.episodeTitle = widget.media.episodes.first.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: VideoViewer(
          // controller: _controller,
          videoContentList: [
            VideoContent(
              quality: widget.media.title,
              videoSource: VideoSource(
                videoPlayerController: VideoPlayerController.networkUrl(
                  Uri.parse(
                    "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                  ),
                ),
                ads: [
                  VideoViewerAd(
                    fractionToStart: 0,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'AD ZERO',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    durationToSkip: Duration.zero,
                  ),
                  VideoViewerAd(
                    fractionToStart: 0.5,
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'AD HALF',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                    durationToSkip: Duration(seconds: 4),
                  ),
                ],
                range: Tween<Duration>(
                  begin: const Duration(seconds: 5),
                  end: const Duration(seconds: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  late Timer timer;

  final ScrollController _controller = ScrollController();
  final List<String> _texts = [];

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      if (mounted) {
        _texts.add("HELLO");
        _controller.jumpTo(_controller.position.maxScrollExtent);
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      color: Colors.black.withAlpha(204),
      child: ListView.builder(
        controller: _controller,
        itemCount: _texts.length,
        itemBuilder: (_, int index) {
          return Text(
            "x$index ${_texts[index]}",
            style: Theme.of(context).textTheme.titleMedium,
          );
        },
      ),
    );
  }
}

class EpisodeThumbnail extends StatelessWidget {
  const EpisodeThumbnail({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  final VoidCallback onTap;
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    const EdgeInsets padding = EdgeInsets.all(20 / 4);
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      child: SizedBox(
        width: 40 * 2,
        height: 40 * 2,
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Positioned.fill(child: Image.network(url, fit: BoxFit.cover)),
            Padding(
              padding: padding,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: padding,
                    color: Theme.of(context).cardColor.withAlpha(41),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: BoxDecoration(shape: BoxShape.rectangle),
                  child: InkWell(
                    onTap: onTap,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
