import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(_url));
    }

    setState(() => _isPlaying = !_isPlaying);
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
            onTap: _togglePlay,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: widget.waGreen,
              child: Icon(
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
