import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AudioMessageBubble extends StatefulWidget {
  final String audioPath;
  final String Function(String) resolveFileUrl;
  final Color waGreen;
  final Color waGreyText;

  const AudioMessageBubble({
    super.key,
    required this.audioPath,
    required this.resolveFileUrl,
    required this.waGreen,
    required this.waGreyText,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isPlaying = false;
  late String _url;
  bool _isDownloading = false;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _url = widget.resolveFileUrl(widget.audioPath);

    _audioPlayer.onDurationChanged.listen((d) {
      setState(() => _audioDuration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      setState(() => _audioPosition = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _audioPosition = Duration.zero;
      });
    });
  }

  @override
  void didUpdateWidget(covariant AudioMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _url = widget.resolveFileUrl(widget.audioPath);
      _localPath = null;
      _isPlaying = false;
      _audioDuration = Duration.zero;
      _audioPosition = Duration.zero;
      _audioPlayer.stop();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  Future<String?> _getLocalAudioPath() async {
    if (_localPath != null && await File(_localPath!).exists()) {
      final file = File(_localPath!);
      final len = await file.length();
      if (len > 0) return _localPath;
    }

    setState(() => _isDownloading = true);
    try {
      Directory? tempDir;
      if (Platform.isAndroid) {
        try {
          final extDirs = await getExternalCacheDirectories();
          if (extDirs != null && extDirs.isNotEmpty) {
            tempDir = extDirs.first;
          }
        } catch (e) {
          debugPrint("⚠️ Failed to get external cache directories: $e");
        }
      }
      tempDir ??= await getTemporaryDirectory();

      String filename = widget.audioPath.split('/').last.split('?').first;
      if (filename.isEmpty) {
        filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }
      final file = File('${tempDir.path}/$filename');

      if (await file.exists()) {
        final len = await file.length();
        if (len > 0) {
          _localPath = file.path;
          debugPrint("🎵 Local audio file already exists: $_localPath ($len bytes)");
          return _localPath;
        }
      }

      debugPrint("📡 Downloading audio from URL: $_url");
      final dio = Dio();
      final response = await dio.download(_url, file.path);
      
      final len = await file.length();
      debugPrint("✅ Download completed. HTTP Status: ${response.statusCode}, File Size: $len bytes");
      
      if (len == 0) {
        debugPrint("⚠️ Downloaded file is empty.");
        return null;
      }

      _localPath = file.path;
      return _localPath;
    } catch (e) {
      debugPrint("❌ Error downloading audio: $e");
      return null;
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      final path = await _getLocalAudioPath();
      try {
        if (path != null) {
          debugPrint("🎵 Attempting play from local path: $path");
          await _audioPlayer.play(DeviceFileSource(path));
        } else {
          debugPrint("🎵 Local path null. Streaming from URL: $_url");
          await _audioPlayer.play(UrlSource(_url));
        }
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("❌ Local playback failed: $e. Falling back to URL streaming.");
        try {
          await _audioPlayer.play(UrlSource(_url));
          setState(() => _isPlaying = true);
        } catch (err) {
          debugPrint("❌ Fallback URL streaming failed: $err");
          setState(() => _isPlaying = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ▶ Play / Pause
          GestureDetector(
            onTap: _isDownloading ? null : _togglePlay,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: widget.waGreen,
              child: _isDownloading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 18,
                      color: Colors.white,
                    ),
            ),
          ),

          const SizedBox(width: 8),

          /// 🎚 Progress bar
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: widget.waGreen,
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: widget.waGreen,
              ),
              child: Slider(
                value: _audioPosition.inMilliseconds
                    .toDouble()
                    .clamp(0, _audioDuration.inMilliseconds.toDouble()),
                max: _audioDuration.inMilliseconds
                    .toDouble()
                    .clamp(1, double.infinity),
                onChanged: (v) {
                  _audioPlayer.seek(Duration(milliseconds: v.toInt()));
                },
              ),
            ),
          ),

          /// ⏱ Time
          Text(
            _formatDuration(
                _isPlaying ? _audioPosition : _audioDuration),
            style: TextStyle(fontSize: 11, color: widget.waGreyText),
          ),
        ],
      ),
    );
  }
}
