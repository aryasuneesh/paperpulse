# PaperPulse Bug Fixes — Design Spec
Date: 2026-04-16

## Overview
Fix 10 issues identified during structural review: 2 critical, 6 warnings, 2 notes. No new packages required.

---

## Section 1 — Credentials & Configuration

**Problem:** Supabase URL and anonKey are hardcoded in `main.dart` and committed to git history.

**Fix:** Use Flutter's built-in `--dart-define` compile-time constants. Introduce `lib/core/config/app_config.dart` with a single `AppConfig` class exposing `supabaseUrl` and `supabaseAnonKey` as `String.fromEnvironment(...)` constants. Add `.env.example` documenting the required keys. Add `.env` to `.gitignore`. Update `main.dart` to read from `AppConfig`.

**Files:**
- `lib/main.dart` — remove hardcoded values, use `AppConfig`
- `lib/core/config/app_config.dart` — new file
- `.env.example` — new file
- `paperpulse_app/.gitignore` — add `.env`

---

## Section 2 — User Identity

**Problem:** `userId: 'user123'` is hardcoded in `bookmark_provider.dart` (×2), `highlight_provider.dart`, and `pdf_reader_screen.dart`. Supabase auth is initialized but not connected to data.

**Fix:** Introduce `lib/core/providers/user_provider.dart` with a `currentUserIdProvider` (`Provider<String>`) that:
1. Reads `Supabase.instance.client.auth.currentUser?.id`
2. Falls back to a stable device-local UUID stored under `paperpulse_device_uuid` in `SharedPreferences` if unauthenticated

All providers and screens read `ref.read(currentUserIdProvider)` instead of the hardcoded string. This ensures existing local data remains consistent and is correctly attributed when real auth lands.

**Files:**
- `lib/core/providers/user_provider.dart` — new file
- `lib/presentation/features/library/providers/bookmark_provider.dart`
- `lib/presentation/features/library/providers/highlight_provider.dart`
- `lib/presentation/features/digest/pdf_reader_screen.dart`

---

## Section 3 — Technical Bug Fixes

### A — Isolate crash: `compute(PdfDocument)`
**File:** `highlight_provider.dart:91`
`PdfDocument` wraps a native C++ object and cannot be serialized across Dart isolates. Replace:
```dart
// Before
final List<int> savedBytes = await compute<PdfDocument, List<int>>(
  (PdfDocument doc) => doc.saveSync(), document);
// After
final List<int> savedBytes = await Future(() => document.saveSync());
```

### B — Race condition on concurrent PDF mutation
**File:** `highlight_provider.dart`
Two concurrent `removeHighlights()` calls both read, modify, and write the same PDF file; the last write wins, silently discarding earlier removals from the embedded PDF. Fix: add a `Map<String, Future<void>> _pdfMutationQueue` field. Each per-paper PDF operation chains onto the existing future for that paper ID using `.then((_) => ...)`, serializing access without a package dependency.

### C — Silent data loss in save methods
**Files:** `highlight_provider.dart:38`, `bookmark_provider.dart:26`
Empty `catch (_) {}` blocks swallow disk and encoding errors silently. Replace with:
```dart
catch (e, st) {
  debugPrint('Failed to persist [highlights|bookmarks]: $e\n$st');
}
```

### D — Disposed-provider state write
**File:** `digest_stack_provider.dart`
`_loadPapers()` is fired-and-forgotten from `build()`; if the provider is disposed before the future resolves, the `state =` assignment throws `StateError`. Fix: add a `bool _disposed = false` field, set it in `ref.onDispose(...)`, and guard the state assignment.

### E — Silent annotation-save failure + missing mounted check
**File:** `pdf_reader_screen.dart:158`
The `catch` block in `_handleAnnotationAdded` only calls `debugPrint` — user sees no feedback on failure. Add a `mounted` check and a `SnackBar` error message after the await.

---

## Section 4 — Code Quality

### F — Duplicated `onDocumentLoaded` callback
**File:** `pdf_reader_screen.dart`
The `onDocumentLoaded` callback body is copy-pasted verbatim for `SfPdfViewer.file` and `SfPdfViewer.network`. Extract into a private `Future<void> _onDocumentLoaded(PdfDocumentLoadedDetails _)` method referenced by both viewers.

### G — HTTP timeout
**File:** `paper_repository.dart:13`
Add `.timeout(const Duration(seconds: 15))` to the `http.get()` call to prevent indefinite hangs on slow networks.

### H — Remove unused `isar` dependency
**File:** `pubspec.yaml`
`isar` and `isar_flutter_libs` are declared as dependencies but have zero usages in the codebase. Remove both entries.

---

## Constraints
- No new packages added
- SharedPreferences access pattern (global `sharedPrefs`) preserved; user_provider reads it via the same global
- `_saveHighlights` / `_saveBookmarks` remain synchronous wrappers (fire-and-forget `Future<bool>` from SharedPreferences is acceptable here)
- `markAsInProgress` inconsistency (note #8 from review) is left as-is; it's correct, just stylistically inconsistent — out of scope

---

## Files Changed Summary

| File | Change |
|------|--------|
| `lib/main.dart` | Use `AppConfig` constants |
| `lib/core/config/app_config.dart` | New — compile-time config |
| `lib/core/providers/user_provider.dart` | New — stable user ID provider |
| `lib/data/repositories/paper_repository.dart` | Add HTTP timeout |
| `lib/data/models/highlight.dart` | No change |
| `lib/presentation/features/digest/providers/digest_stack_provider.dart` | Disposal guard |
| `lib/presentation/features/digest/pdf_reader_screen.dart` | Extract callback, mounted check, error SnackBar, use `currentUserIdProvider` |
| `lib/presentation/features/library/providers/highlight_provider.dart` | Fix isolate crash, race condition, silent catch, use `currentUserIdProvider` |
| `lib/presentation/features/library/providers/bookmark_provider.dart` | Fix silent catch, use `currentUserIdProvider` |
| `paperpulse_app/.gitignore` | Add `.env` |
| `.env.example` | New — documents required dart-define keys |
| `pubspec.yaml` | Remove `isar` + `isar_flutter_libs` |
