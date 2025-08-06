import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // For development: Handle MissingPluginException gracefully
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('Attempting Google Sign-In...');
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        return {
          'success': true,
          'user': {
            'id': googleUser.id,
            'name': googleUser.displayName,
            'email': googleUser.email,
            'photoUrl': googleUser.photoUrl,
          },
          'tokens': {
            'idToken': googleAuth.idToken,
            'accessToken': googleAuth.accessToken,
          }
        };
      } else {
        return {
          'success': false,
          'error': 'User cancelled sign in',
        };
      }
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code} - ${e.message}');
      
      if (e.code == 'sign_in_failed') {
        return {
          'success': false,
          'error': 'Sign in failed. Please try again.',
        };
      } else {
        return {
          'success': false,
          'error': 'Platform error: ${e.message}',
        };
      }
    } on MissingPluginException catch (e) {
      print('MissingPluginException: ${e.message}');
      
      // For development: Return mock data when plugin is not configured
      if (e.message?.contains('google_sign_in') == true) {
        print('Google Sign-In plugin not configured. Using mock data for development.');
        
        // Return mock user data for development
        return {
          'success': true,
          'mock': true,
          'user': {
            'id': 'mock_user_123',
            'name': 'Test User',
            'email': 'test@example.com',
            'photoUrl': null,
          },
          'tokens': {
            'idToken': 'mock_id_token',
            'accessToken': 'mock_access_token',
          }
        };
      }
      
      return {
        'success': false,
        'error': 'Plugin configuration missing: ${e.message}',
      };
    } catch (e) {
      print('Unknown error: $e');
      return {
        'success': false,
        'error': 'Unknown error occurred: $e',
      };
    }
  }

  static Future<bool> signOut() async {
    try {
      // Sign out from Google Sign-In
      await _googleSignIn.signOut();
      
      // Also disconnect to ensure complete sign out
      await _googleSignIn.disconnect();
      
      print('Successfully signed out from all services');
      return true;
    } on MissingPluginException catch (e) {
      // Handle case where plugin is not configured
      print('Google Sign-In plugin not configured, but considering logout successful: ${e.message}');
      return true; // Return true for development purposes
    } catch (e) {
      print('Sign out error: $e');
      return false;
    }
  }

  // Check if user is currently signed in
  static Future<bool> isSignedIn() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Check sign in status error: $e');
      return false;
    }
  }

  // Get current user information
  static Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final GoogleSignInAccount? currentUser = await _googleSignIn.signInSilently();
      
      if (currentUser != null) {
        final GoogleSignInAuthentication auth = await currentUser.authentication;
        
        return {
          'user': {
            'id': currentUser.id,
            'name': currentUser.displayName,
            'email': currentUser.email,
            'photoUrl': currentUser.photoUrl,
          },
          'tokens': {
            'idToken': auth.idToken,
            'accessToken': auth.accessToken,
          }
        };
      }
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      return await _googleSignIn.signInSilently();
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
}