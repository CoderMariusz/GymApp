import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/presentation/providers/meditation_providers.dart';

/// Card widget for displaying a meditation
class MeditationCard extends ConsumerStatefulWidget {
  final MeditationEntity meditation;
  final bool isGridView;

  const MeditationCard({
    super.key,
    required this.meditation,
    this.isGridView = true,
  });

  @override
  ConsumerState<MeditationCard> createState() => _MeditationCardState();
}

class _MeditationCardState extends ConsumerState<MeditationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _isFavorite = widget.meditation.isFavorited;
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onMeditationTap(context),
        child: widget.isGridView ? _buildGridCard() : _buildListCard(),
      ),
    );
  }

  Widget _buildGridCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail
        AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildThumbnail(),
              _buildPremiumBadge(),
              _buildFavoriteButton(),
            ],
          ),
        ),
        // Info
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meditation.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _buildMetadata(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListCard() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          // Thumbnail
          AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildThumbnail(),
                _buildPremiumBadge(),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meditation.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.meditation.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  _buildMetadata(),
                ],
              ),
            ),
          ),
          // Favorite button
          _buildFavoriteButton(),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return CachedNetworkImage(
      imageUrl: widget.meditation.thumbnailUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Icon(
          Icons.self_improvement,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    if (!widget.meditation.isPremium) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'PREMIUM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: AnimatedScale(
        scale: _isFavorite ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: _toggleFavorite,
        ),
      ),
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // Duration
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          widget.meditation.durationFormatted,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        // Category badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getCategoryColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.meditation.category.displayName,
            style: TextStyle(
              fontSize: 10,
              color: _getCategoryColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (widget.meditation.completionCount > 0) ...[
          const SizedBox(width: 8),
          Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.green[600],
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.meditation.completionCount}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[600],
            ),
          ),
        ],
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.meditation.category) {
      case MeditationCategory.stressRelief:
        return Colors.blue;
      case MeditationCategory.sleep:
        return Colors.purple;
      case MeditationCategory.focus:
        return Colors.orange;
      case MeditationCategory.anxiety:
        return Colors.teal;
      case MeditationCategory.gratitude:
        return Colors.pink;
    }
  }

  void _toggleFavorite() async {
    HapticFeedback.lightImpact();

    setState(() {
      _isFavorite = !_isFavorite;
    });

    _favoriteController.forward().then((_) => _favoriteController.reverse());

    // Get current user ID from auth provider
    final authState = ref.read(authStateProvider);
    final userId = authState.maybeMap(
      authenticated: (auth) => auth.user.id,
      orElse: () => null,
    );

    if (userId == null) {
      // User not authenticated
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save favorites')),
        );
      }
      return;
    }

    final useCase = ref.read(toggleFavoriteUseCaseProvider);
    final result = await useCase(
      userId: userId,
      meditationId: widget.meditation.id,
    );

    result.map(
      success: (success) {
        if (success.data != _isFavorite) {
          setState(() {
            _isFavorite = success.data;
          });
        }
      },
      failure: (failure) {
        // Revert on error
        setState(() {
          _isFavorite = !_isFavorite;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update favorite: ${failure.exception}')),
          );
        }
      },
    );
  }

  void _onMeditationTap(BuildContext context) {
    // TODO: Navigate to meditation player screen (Story 4.2)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playing ${widget.meditation.title}')),
    );
  }
}
