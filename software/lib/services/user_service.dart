import 'package:medvend/app/app.locator.dart';
import 'package:medvend/models/app_user.dart';
import 'package:medvend/services/firestore_service.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';

class UserService {
  final _authenticationService = locator<FirebaseAuthenticationService>();
  final _firestoreService = locator<FirestoreService>();

  AppUser? _user;
  AppUser? get user => _user;

  bool get hasLoggedInUser => _authenticationService.hasUser;

  // Creates or updates a user profile in Firestore
  Future<String?> createUpdateUser(AppUser user) async {
    try {
      bool result = await _firestoreService.createUser(user: user);
      return result ? null : "Error uploading data";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Logs in a user with email and password using Firebase Authentication
  Future<String?> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _authenticationService.loginWithEmail(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return "Login failed: Incorrect credentials or other error";
      }

      return null; // Null indicates success
    } catch (e) {
      return "Login failed: $e";
    }
  }

  // Registers a new user with email and password
  Future<String?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      final result = await _authenticationService.createAccountWithEmail(
        email: email,
        password: password,
      );

      if (result.user == null) {
        return "Registration failed: Could not create account";
      }

      return null;
    } catch (e) {
      return "Registration failed: $e";
    }
  }

  // Fetches the user profile from Firestore
  Future<AppUser?> fetchUser() async {
    final uid = _authenticationService.currentUser?.uid;
    if (uid != null) {
      _user = await _firestoreService.getUser(userId: uid);
    }
    return _user;
  }

  // Logs out the user
  Future<void> logout() async {
    await _authenticationService.logout();
    _user = null;
  }

  // Fetch all patients from Firestore who have the role of 'Patient'
  Future<List<AppUser>> getPatients() async {
    try {
      // Fetch users with role 'Patient'
      return await _firestoreService.getUsersWithRole('Patient');
    } catch (e) {
      print("Error fetching patients: $e");
      return [];
    }
  }
}
