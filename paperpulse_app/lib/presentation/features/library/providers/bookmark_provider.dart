import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart' show sharedPrefs;
import '../../../../core/providers/user_provider.dart';
import '../../../../data/models/bookmark.dart';
import '../../../../data/models/paper.dart';

final bookmarkProvider = NotifierProvider<BookmarkNotifier, List<Bookmark>>(
  BookmarkNotifier.new,
);

class BookmarkNotifier extends Notifier<List<Bookmark>> {
  static const _prefsKey = 'paperpulse_bookmarks';

  @override
  List<Bookmark> build() {
    final currentUserId = ref.watch(currentUserIdProvider);
    return _loadBookmarks(currentUserId);
  }

  List<Bookmark> _loadBookmarks(String currentUserId) {
    try {
      final String? data = sharedPrefs.getString(_prefsKey);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        return jsonList
            .whereType<Map<String, dynamic>>()
            .map((e) {
              try {
                return Bookmark.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<Bookmark>()
            .where((b) => b.userId == currentUserId)
            .toList();
      }
    } catch (e, st) {
      debugPrint('Failed to load bookmarks: $e\n$st');
    }
    return [];
  }

  void _saveBookmarks(List<Bookmark> bookmarks) {
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      List<Map<String, dynamic>> allBookmarks = [];
      final String? existing = sharedPrefs.getString(_prefsKey);
      if (existing != null) {
        final decoded = jsonDecode(existing) as List;
        allBookmarks = decoded
            .whereType<Map<String, dynamic>>()
            .where((e) => e['userId'] != currentUserId)
            .toList();
      }
      allBookmarks.addAll(bookmarks.map((e) => e.toJson()));
      sharedPrefs.setString(_prefsKey, jsonEncode(allBookmarks));
    } catch (e, st) {
      debugPrint('Failed to persist bookmarks: $e\n$st');
    }
  }

  void toggleBookmark(Paper paper) {
    if (state.any((b) => b.paperId == paper.id)) {
      state = state.where((b) => b.paperId != paper.id).toList();
    } else {
      state = [
        ...state,
        Bookmark(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: ref.read(currentUserIdProvider),
          paperId: paper.id,
          createdAt: DateTime.now(),
          status: BookmarkStatus.unread,
          topicTags: paper.topicTags,
        ),
      ];
    }
    _saveBookmarks(state);
  }

  void markAsInProgress(Paper paper) {
    if (isBookmarked(paper.id)) {
      updateStatus(paper.id, BookmarkStatus.in_progress);
    } else {
      state = [
        ...state,
        Bookmark(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: ref.read(currentUserIdProvider),
          paperId: paper.id,
          createdAt: DateTime.now(),
          status: BookmarkStatus.in_progress,
          topicTags: paper.topicTags,
        ),
      ];
      _saveBookmarks(state);
    }
  }

  void updateStatus(String paperId, BookmarkStatus newStatus) {
    state = [
      for (final bookmark in state)
        if (bookmark.paperId == paperId)
          Bookmark(
            id: bookmark.id,
            userId: bookmark.userId,
            paperId: bookmark.paperId,
            createdAt: bookmark.createdAt,
            status: newStatus,
            topicTags: bookmark.topicTags,
          )
        else
          bookmark,
    ];
    _saveBookmarks(state);
  }

  bool isBookmarked(String paperId) {
    return state.any((b) => b.paperId == paperId);
  }

  List<String> getBookmarkedPaperIds(BookmarkStatus? status) {
    if (status == null) return state.map((b) => b.paperId).toList();
    return state
        .where((b) => b.status == status)
        .map((b) => b.paperId)
        .toList();
  }
}
