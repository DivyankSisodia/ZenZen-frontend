import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zenzen/data/api/auth_api.dart';
import '../../../../data/failure.dart';
import '../model/user_model.dart';

class OAuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AuthApiService _apiService;

  OAuthRepository({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required AuthApiService apiService,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _apiService = apiService;

  Future<Either<AuthFailure, UserCredential>> signInWithGoogle(
      bool isLogin) async {
    try {
      // Web platform specific implementation
      if (kIsWeb) {
        // Use Firebase Auth directly with Google provider for web
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        // Add scopes if needed
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        googleProvider.setCustomParameters(
            {'login_hint': 'user@example.com', 'prompt': 'select_account'});

        // Sign in with popup for better UX
        final userCredential = await _auth.signInWithPopup(googleProvider);

        if (userCredential.user == null) {
          return left(AuthFailure('Failed to get user from Firebase'));
        }

        print("user info ${userCredential.user!.providerData}");

        final apiResult = isLogin == true
            ? await _apiService.login(
                userCredential.user!.email!,
                userCredential.user!.uid,
              )
            : await _apiService.signUp(
                userCredential.user!.email!,
                userCredential.user!.uid,
              );

        print("apiResult ${apiResult.fold((l) => l, (r) => r.error)}");

        return apiResult.fold(
          (user) => right(userCredential),
          (failure) => left(AuthFailure(failure.error)),
        );
      }
      // Mobile implementation - keep your existing code
      else {
        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return left(AuthFailure('Google sign in was aborted by user'));
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user == null) {
          return left(AuthFailure('Failed to get user from Firebase'));
        }

        final apiResult = isLogin == true
            ? await _apiService.login(
                userCredential.user!.email!,
                userCredential.user!.uid,
              )
            : await _apiService.register(
                userCredential.user!.email!,
                userCredential.user!.uid,
              );

        return apiResult.fold(
          (user) => right(userCredential),
          (failure) => left(AuthFailure(failure.error)),
        );
      }
    } on FirebaseAuthException catch (e) {
      return left(
          AuthFailure(e.message ?? 'Authentication failed', code: e.code));
    } catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  // Get current user
  Future<Either<UserModel, AuthFailure>> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return right(AuthFailure.custom('No user is signed in'));
      }

      return await _apiService.getUser();
    } catch (e) {
      return right(AuthFailure.custom(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
