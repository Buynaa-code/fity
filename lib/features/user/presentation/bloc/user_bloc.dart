import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/datasources/auth/auth_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final SharedPreferences _prefs;

  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhotoKey = 'user_photo';
  static const String _userIdKey = 'user_id';

  UserBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const UserState()) {
    on<LoadUser>(_onLoadUser);
    on<RefreshUser>(_onRefreshUser);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onLoadUser(
    LoadUser event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      // First try to load from cached preferences
      final cachedName = _prefs.getString(_userNameKey);
      final cachedEmail = _prefs.getString(_userEmailKey);
      final cachedPhoto = _prefs.getString(_userPhotoKey);
      final cachedId = _prefs.getString(_userIdKey);

      if (cachedId != null && cachedName != null) {
        emit(state.copyWith(
          userId: cachedId,
          userName: cachedName,
          email: cachedEmail,
          photoUrl: cachedPhoto,
          status: UserStatus.loaded,
        ));

        // Try to refresh in background
        _refreshFromAuth();
        return;
      }

      // Try to get from auth service
      final userInfo = await AuthService.getCurrentUserInfo();

      if (userInfo != null && userInfo['user'] != null) {
        final user = userInfo['user'] as Map<String, dynamic>;
        final name = user['name'] as String? ?? '';
        final email = user['email'] as String?;
        final photoUrl = user['photoUrl'] as String?;
        final userId = user['id'] as String?;

        // Cache the user data
        if (userId != null) await _prefs.setString(_userIdKey, userId);
        if (name.isNotEmpty) await _prefs.setString(_userNameKey, name);
        if (email != null) await _prefs.setString(_userEmailKey, email);
        if (photoUrl != null) await _prefs.setString(_userPhotoKey, photoUrl);

        emit(state.copyWith(
          userId: userId,
          userName: name,
          email: email,
          photoUrl: photoUrl,
          status: UserStatus.loaded,
        ));
      } else {
        // No user logged in - use default guest
        emit(state.copyWith(
          userName: 'Guest',
          status: UserStatus.loaded,
        ));
      }
    } catch (e) {
      // On error, still show guest user
      emit(state.copyWith(
        userName: 'Guest',
        status: UserStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _refreshFromAuth() async {
    try {
      final userInfo = await AuthService.getCurrentUserInfo();
      if (userInfo != null && userInfo['user'] != null) {
        final user = userInfo['user'] as Map<String, dynamic>;
        final name = user['name'] as String? ?? '';
        final email = user['email'] as String?;
        final photoUrl = user['photoUrl'] as String?;
        final userId = user['id'] as String?;

        if (userId != null) await _prefs.setString(_userIdKey, userId);
        if (name.isNotEmpty) await _prefs.setString(_userNameKey, name);
        if (email != null) await _prefs.setString(_userEmailKey, email);
        if (photoUrl != null) await _prefs.setString(_userPhotoKey, photoUrl);
      }
    } catch (_) {
      // Silently ignore refresh errors
    }
  }

  Future<void> _onRefreshUser(
    RefreshUser event,
    Emitter<UserState> emit,
  ) async {
    try {
      final userInfo = await AuthService.getCurrentUserInfo();

      if (userInfo != null && userInfo['user'] != null) {
        final user = userInfo['user'] as Map<String, dynamic>;
        final name = user['name'] as String? ?? '';
        final email = user['email'] as String?;
        final photoUrl = user['photoUrl'] as String?;
        final userId = user['id'] as String?;

        // Cache the user data
        if (userId != null) await _prefs.setString(_userIdKey, userId);
        if (name.isNotEmpty) await _prefs.setString(_userNameKey, name);
        if (email != null) await _prefs.setString(_userEmailKey, email);
        if (photoUrl != null) await _prefs.setString(_userPhotoKey, photoUrl);

        emit(state.copyWith(
          userId: userId,
          userName: name,
          email: email,
          photoUrl: photoUrl,
          status: UserStatus.loaded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<UserState> emit,
  ) async {
    try {
      await AuthService.signOut();

      // Clear cached data
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_userNameKey);
      await _prefs.remove(_userEmailKey);
      await _prefs.remove(_userPhotoKey);

      emit(const UserState(
        status: UserStatus.unauthenticated,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }
}
