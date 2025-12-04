import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/presentation/providers/meditation_providers.dart';

/// Provider for audio player instance per meditation
final audioPlayerProvider = StateProvider.family<AudioPlayer, String>((ref, meditationId) {
  return AudioPlayer();
});

/// Provider for meditation session state
final meditationSessionProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (userId, meditationId) = params;
    final useCase = ref.watch(toggleFavoriteUseCaseProvider);
    // Log session completion
    // TODO: Save to MeditationSessions table
    return true;
  },
);

/// Meditation Player Screen
/// Displays a full-featured audio player for meditation sessions
class MeditationPlayerScreen extends ConsumerStatefulWidget {
  final MeditationEntity meditation;

  const MeditationPlayerScreen({
    super.key,
    required this.meditation,
  });

  @override
  ConsumerState<MeditationPlayerScreen> createState() =>
      _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends ConsumerState<MeditationPlayerScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = ref.read(audioPlayerProvider(widget.meditation.id));
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Listen to player state changes
      _audioPlayer.playerStateStream.listen((playerState) {
        setState(() {
          _isPlaying = playerState.playing;
        });
      });

      // Listen to position changes
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentDuration = position;
        });
      });

      // Listen to duration changes
      _audioPlayer.durationStream.listen((duration) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      });

      // Load audio from URL
      if (widget.meditation.audioUrl.isNotEmpty) {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse(widget.meditation.audioUrl)),
        );
      } else {
        // Fallback: show error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio file not available')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: $e')),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _seekTo(Duration duration) async {
    try {
      await _audioPlayer.seek(duration);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error seeking: $e')),
        );
      }
    }
  }

  Future<void> _skipForward() async {
    final newPosition = _currentDuration + const Duration(seconds: 15);
    if (newPosition < _totalDuration) {
      await _seekTo(newPosition);
    }
  }

  Future<void> _skipBackward() async {
    final newPosition = _currentDuration - const Duration(seconds: 15);
    if (newPosition > Duration.zero) {
      await _seekTo(newPosition);
    } else {
      await _seekTo(Duration.zero);
    }
  }

  Future<void> _logSessionCompletion() async {
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeMap(
      authenticated: (auth) => auth.user.id,
      orElse: () => null,
    );

    if (userId != null) {
      // TODO: Save to MeditationSessions table
      // timestamp, userId, meditationId, duration_listened
    }
  }

  @override
  void dispose() {
    _logSessionCompletion();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _audioPlayer.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.expand_more),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showMoreOptions,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Artwork
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: widget.meditation.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: Icon(
                            Icons.self_improvement,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Title and description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meditation.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.meditation.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),

                        // Progress bar
                        _buildProgressBar(),
                        const SizedBox(height: 16),

                        // Controls
                        _buildControls(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 12,
            ),
          ),
          child: Slider(
            value: _currentDuration.inSeconds.toDouble(),
            max: _totalDuration.inSeconds.toDouble(),
            activeColor: Colors.cyan,
            inactiveColor: Colors.grey[700],
            onChanged: (value) {
              _seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentDuration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Skip buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip backward button
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.replay_15),
              color: Colors.white,
              onPressed: _skipBackward,
            ),
            const SizedBox(width: 24),

            // Play/Pause button
            Container(
              decoration: BoxDecoration(
                color: Colors.cyan,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                iconSize: 48,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                ),
                onPressed: _togglePlayPause,
              ),
            ),
            const SizedBox(width: 24),

            // Skip forward button
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.forward_15),
              color: Colors.white,
              onPressed: _skipForward,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Speed controls (optional)
        _buildSpeedControls(),
      ],
    );
  }

  Widget _buildSpeedControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SpeedButton(
            label: '0.75x',
            onPressed: () => _audioPlayer.setSpeed(0.75),
          ),
          _SpeedButton(
            label: '1x',
            onPressed: () => _audioPlayer.setSpeed(1.0),
          ),
          _SpeedButton(
            label: '1.25x',
            onPressed: () => _audioPlayer.setSpeed(1.25),
          ),
          _SpeedButton(
            label: '1.5x',
            onPressed: () => _audioPlayer.setSpeed(1.5),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.grey[900],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Add to favorites'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement favorites
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sharing
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement download via downloadMeditationUseCase
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Speed control button widget
class _SpeedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SpeedButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.cyan),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
