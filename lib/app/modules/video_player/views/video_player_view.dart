import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';

/// Plays YouTube links with the YouTube player and any other video / stream
/// URL (mp4, m3u8, ...) with the standard video_player package.
class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key});

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  YoutubePlayerController? _ytController;
  vp.VideoPlayerController? _videoController;
  bool _videoError = false;
  String? videoUrl;
  String? videoTitle;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    videoUrl = args?['url'] as String?;
    videoTitle = args?['title'] as String? ?? 'Video Player';

    if (videoUrl == null) return;

    if (_isYouTubeUrl(videoUrl!)) {
      final videoId = YoutubePlayer.convertUrlToId(videoUrl!);
      if (videoId != null) {
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
          ),
        );
      }
    } else {
      _initNetworkVideo(videoUrl!);
    }
  }

  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  Future<void> _initNetworkVideo(String url) async {
    try {
      final controller = vp.VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = controller;
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      await controller.initialize();
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ytController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _ytController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primary,
          progressColors: ProgressBarColors(
            playedColor: AppTheme.primary,
            handleColor: AppTheme.accent,
          ),
        ),
        builder: (context, player) => _scaffold(
          player: player,
          onFullscreen: () => _ytController!.toggleFullScreenMode(),
        ),
      );
    }

    // Network video (mp4 / m3u8 / other streams)
    final vc = _videoController;
    Widget player;
    if (videoUrl == null || _videoError || (vc == null)) {
      player = AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: EmptyState(
            icon: Icons.videocam_off_rounded,
            message: videoUrl == null
                ? 'No video URL provided'
                : 'This video could not be played',
          ),
        ),
      );
    } else if (!vc.value.isInitialized) {
      player = const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(color: Colors.black, child: AppLoader()),
      );
    } else {
      player = AspectRatio(
        aspectRatio: vc.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            vp.VideoPlayer(vc),
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    vc.value.isPlaying ? vc.pause() : vc.play(),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: vc.value.isPlaying ? 0 : 1,
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: AppTheme.glow(),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            vp.VideoProgressIndicator(
              vc,
              allowScrubbing: true,
              colors: const vp.VideoProgressColors(
                playedColor: AppTheme.primary,
                bufferedColor: Color(0x55FFFFFF),
                backgroundColor: Color(0x22FFFFFF),
              ),
            ),
          ],
        ),
      );
    }
    return _scaffold(player: player);
  }

  Widget _scaffold({required Widget player, VoidCallback? onFullscreen}) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: glassAppBar(
        videoTitle ?? 'Video Player',
        onBack: () => Get.back(),
        actions: [
          if (onFullscreen != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GlassIconButton(
                icon: Icons.fullscreen_rounded,
                size: 40,
                onTap: onFullscreen,
              ),
            ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(boxShadow: AppTheme.glow()),
              child: player,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FadeSlideIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LiveBadge(text: 'NOW PLAYING'),
                      const SizedBox(height: 14),
                      Text(
                        videoTitle ?? 'Live Stream',
                        style: AppTheme.heading(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join us in worship wherever you are.',
                        style: AppTheme.body(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
