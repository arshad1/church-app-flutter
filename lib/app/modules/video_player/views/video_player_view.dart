import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_theme.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  String? videoUrl;
  String? videoTitle;

  @override
  void initState() {
    super.initState();

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    videoUrl = args?['url'] as String?;
    videoTitle = args?['title'] as String? ?? 'Video Player';

    if (videoUrl != null && _isYouTubeUrl(videoUrl!)) {
      _initializeYouTubePlayer();
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  void _initializeYouTubePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(videoUrl!);

    if (videoId != null) {
      _controller =
          YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              enableCaption: true,
              controlsVisibleAtStart: true,
            ),
          )..addListener(() {
            if (_controller.value.isReady && !_isPlayerReady) {
              setState(() {
                _isPlayerReady = true;
              });
            }
          });
    }
  }

  @override
  void dispose() {
    if (_isYouTubeUrl(videoUrl ?? '')) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoUrl == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          title: const Text('Video Player'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(
          child: Text(
            'No video URL provided',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primary,
        progressColors: ProgressBarColors(
          playedColor: AppTheme.primary,
          handleColor: AppTheme.primary,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              videoTitle ?? 'Video Player',
              style: const TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _controller.value.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: () {
                  _controller.toggleFullScreenMode();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: Container(
                  color: AppTheme.background,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoTitle ?? 'Live Stream',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
