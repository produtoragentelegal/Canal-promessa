import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your widget name, define your parameter, and then add the
// boilerplate code using the green button on the right!

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class CustomVidPlayer extends StatefulWidget {
  CustomVidPlayer({
    Key? key,
    this.width,
    this.height,
    required this.videoPath,
    this.playPauseVideoAction = false,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = false,
    this.allowFullScreen = false,
    this.allowPlayBackSpeedChanging = false,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String videoPath;
  final bool playPauseVideoAction;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlayBackSpeedChanging;

  @override
  _CustomVidPlayerState createState() => _CustomVidPlayerState();
}

class _CustomVidPlayerState extends State<CustomVidPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _errorMessage;
  bool _isInitializing = true;
  int _initializationToken = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(CustomVidPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath ||
        widget.looping != oldWidget.looping ||
        widget.autoPlay != oldWidget.autoPlay ||
        widget.showControls != oldWidget.showControls ||
        widget.allowFullScreen != oldWidget.allowFullScreen ||
        widget.allowPlayBackSpeedChanging !=
            oldWidget.allowPlayBackSpeedChanging) {
      _initializePlayer();
      return;
    }

    if (widget.playPauseVideoAction != oldWidget.playPauseVideoAction) {
      _syncPlaybackWithRequestedAction();
    }
  }

  @override
  void dispose() {
    _initializationToken++;
    _disposeControllers();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final uri = Uri.tryParse(widget.videoPath);
    if (uri == null || !uri.hasScheme) {
      setState(() {
        _disposeControllers();
        _isInitializing = false;
        _errorMessage = 'URL de video invalida.';
      });
      return;
    }

    final initializationToken = ++_initializationToken;
    _disposeControllers();

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    final videoPlayerController = VideoPlayerController.networkUrl(
      uri,
      formatHint: _inferVideoFormat(uri),
    );

    try {
      await videoPlayerController.initialize();
      await videoPlayerController.setLooping(widget.looping);

      final aspectRatio = videoPlayerController.value.aspectRatio > 0
          ? videoPlayerController.value.aspectRatio
          : 16 / 9;

      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: aspectRatio,
        autoPlay: widget.autoPlay || widget.playPauseVideoAction,
        looping: widget.looping,
        showControls: widget.showControls,
        allowFullScreen: widget.allowFullScreen,
        allowPlaybackSpeedChanging: widget.allowPlayBackSpeedChanging,
        errorBuilder: (context, errorMessage) =>
            _buildErrorState(errorMessage: errorMessage),
      );

      if (!mounted || initializationToken != _initializationToken) {
        chewieController.dispose();
        videoPlayerController.dispose();
        return;
      }

      setState(() {
        _videoPlayerController = videoPlayerController;
        _chewieController = chewieController;
        _isInitializing = false;
      });
    } catch (error) {
      videoPlayerController.dispose();

      if (!mounted || initializationToken != _initializationToken) {
        return;
      }

      setState(() {
        _disposeControllers();
        _isInitializing = false;
        _errorMessage = _buildFriendlyErrorMessage(error);
      });
    }
  }

  void _disposeControllers() {
    final chewieController = _chewieController;
    final videoPlayerController = _videoPlayerController;

    _chewieController = null;
    _videoPlayerController = null;

    chewieController?.dispose();
    videoPlayerController?.dispose();
  }

  void _syncPlaybackWithRequestedAction() {
    final videoPlayerController = _videoPlayerController;
    if (videoPlayerController == null ||
        !videoPlayerController.value.isInitialized) {
      return;
    }

    if (widget.playPauseVideoAction) {
      videoPlayerController.play();
    } else {
      videoPlayerController.pause();
    }
  }

  VideoFormat? _inferVideoFormat(Uri uri) {
    final source = uri.toString().toLowerCase();

    if (source.contains('.m3u8')) {
      return VideoFormat.hls;
    }
    if (source.contains('.mpd')) {
      return VideoFormat.dash;
    }
    if (source.contains('.ism')) {
      return VideoFormat.ss;
    }

    return null;
  }

  String _buildFriendlyErrorMessage(Object error) {
    final source = widget.videoPath.toLowerCase();
    if (source.contains('/player/')) {
      return 'Use a URL direta do stream, como .m3u8 ou .mp4.';
    }

    return 'Nao foi possivel carregar a transmissao. Confira se a URL aponta para um stream de video valido.';
  }

  void _toggleVideoPlayback() {
    final videoPlayerController = _videoPlayerController;
    if (videoPlayerController == null ||
        !videoPlayerController.value.isInitialized) {
      return;
    }

    if (videoPlayerController.value.isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  }

  Widget _buildErrorState({String? errorMessage}) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.live_tv_rounded,
              color: Colors.white70,
              size: 56.0,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Nao foi possivel carregar a transmissao.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              errorMessage ??
                  'Verifique se a URL aponta diretamente para um stream suportado.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chewieController = _chewieController;
    final videoPlayerController = _videoPlayerController;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _errorMessage != null
          ? _buildErrorState(errorMessage: _errorMessage)
          : _isInitializing || chewieController == null || videoPlayerController == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    Chewie(
                      controller: chewieController,
                    ),
                    if (!widget.showControls)
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _toggleVideoPlayback,
                          behavior: HitTestBehavior.opaque,
                        ),
                      ),
                  ],
                ),
    );
  }
}
