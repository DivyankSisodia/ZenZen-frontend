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
      if (kIsWeb) {
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
                "test1234",
              )
            : await _apiService.signUp(
                userCredential.user!.email!,
                "test1234",
              );

        print("apiResult ${apiResult.fold((l) => l, (r) => r.error)}");

        return apiResult.fold(
          (user) => right(userCredential),
          (failure) => left(AuthFailure(failure.error)),
        );
      }
      
      else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return left(AuthFailure('Google sign in was aborted by user'));
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.user == null) {
          return left(AuthFailure('Failed to get user from Firebase'));
        }

        final apiResult = isLogin == true
            ? await _apiService.login(
                userCredential.user!.email!,
                "test1234",
              )
            : await _apiService.signUp(
                userCredential.user!.email!,
                "test1234",
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
  Future<Either<UserModel, ApiFailure>> getCurrentUser(String? token) async {
    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        return right(ApiFailure.custom('No user is signed in'));
      }

      return await _apiService.getUser(token!);
    } catch (e) {
      return right(ApiFailure.custom(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
