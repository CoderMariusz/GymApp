import 'package:lifeos/core/error/exceptions.dart';
import 'package:lifeos/features/mind_emotion/data/models/meditation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for meditation data (Supabase)
abstract class MeditationRemoteDataSource {
  Future<List<MeditationModel>> getMeditations();
  Future<MeditationModel> getMeditationById(String id);
  Future<void> toggleFavorite(String userId, String meditationId);
  Future<List<String>> getFavoriteIds(String userId);
  Future<void> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  });
  Future<int> getCompletionCount(String userId, String meditationId);
}

class MeditationRemoteDataSourceImpl implements MeditationRemoteDataSource {
  final SupabaseClient _supabase;

  MeditationRemoteDataSourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<MeditationModel>> getMeditations() async {
    try {
      final response = await _supabase
          .from('meditations')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MeditationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch meditations: $e');
    }
  }

  @override
  Future<MeditationModel> getMeditationById(String id) async {
    try {
      final response = await _supabase
          .from('meditations')
          .select()
          .eq('id', id)
          .single();

      return MeditationModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch meditation: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String userId, String meditationId) async {
    try {
      // Check if already favorited
      final existing = await _supabase
          .from('meditation_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('meditation_id', meditationId)
          .maybeSingle();

      if (existing != null) {
        // Remove favorite
        await _supabase
            .from('meditation_favorites')
            .delete()
            .eq('user_id', userId)
            .eq('meditation_id', meditationId);
      } else {
        // Add favorite
        await _supabase.from('meditation_favorites').insert({
          'user_id': userId,
          'meditation_id': meditationId,
        });
      }
    } catch (e) {
      throw ServerException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final response = await _supabase
          .from('meditation_favorites')
          .select('meditation_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['meditation_id'] as String)
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch favorite IDs: $e');
    }
  }

  @override
  Future<void> trackSession({
    required String userId,
    required String meditationId,
    required int durationListened,
    required bool completed,
  }) async {
    try {
      await _supabase.from('meditation_sessions').insert({
        'user_id': userId,
        'meditation_id': meditationId,
        'duration_listened_seconds': durationListened,
        'completed': completed,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
    } catch (e) {
      throw ServerException('Failed to track session: $e');
    }
  }

  @override
  Future<int> getCompletionCount(String userId, String meditationId) async {
    try {
      final response = await _supabase
          .from('meditation_sessions')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', userId)
          .eq('meditation_id', meditationId)
          .eq('completed', true);

      return response.count ?? 0;
    } catch (e) {
      throw ServerException('Failed to get completion count: $e');
    }
  }
}
