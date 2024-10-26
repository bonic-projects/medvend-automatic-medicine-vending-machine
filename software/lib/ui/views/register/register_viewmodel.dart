import 'package:medvend/app/app.locator.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:medvend/app/app.router.dart';
import 'package:medvend/models/app_user.dart';

import 'package:medvend/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'register_view.form.dart';

class RegisterViewModel extends FormViewModel {
  final log = getLogger('RegisterViewModel');
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      locator<FirebaseAuthenticationService>();
  final _navigationService = locator<NavigationService>();
  final _snackBarService = locator<SnackbarService>();
  final _userService = locator<UserService>();

  List<String> departments = ['Cardiology', 'Neurology', 'Orthopedics'];
  String? department; // Holds selected department if Doctor is chosen

  // Set the department selected by the Doctor
  void setDepartment(String dept) {
    department = dept;
    notifyListeners();
  }

  /// Register the user with email and password and create their profile in Firestore.
  Future<void> registerUser() async {
    validateForm(); // Ensure validation triggers on button press

    if (isFormValid &&
        emailValue != null &&
        passwordValue != null &&
        nameValue != null &&
        userRoleValue != null) {
      setBusy(true); // Show loading indicator
      log.i("Registering user with email: $emailValue");

      FirebaseAuthenticationResult result =
          await _firebaseAuthenticationService.createAccountWithEmail(
        email: emailValue!,
        password: passwordValue!,
      );

      if (result.user != null) {
        String? error = await _userService.createUpdateUser(AppUser(
          id: result.user!.uid,
          fullName: nameValue!,
          email: result.user!.email!,
          userRole: userRoleValue!,
          regTime: DateTime.now(),
          photoUrl: "",
        ));

        if (error == null) {
          await _userService.fetchUser();

          if (_userService.user!.userRole == "Patient") {
            _navigationService.pushNamedAndRemoveUntil(Routes.patientView);
          } else if (_userService.user!.userRole == "Doctor") {
            _navigationService.pushNamedAndRemoveUntil(Routes.doctorView);
          }
        } else {
          _snackBarService.showSnackbar(message: error);
        }
      } else {
        _snackBarService.showSnackbar(
          message: result.errorMessage ?? "Registration failed.",
        );
      }

      setBusy(false); // Hide loading indicator
    } else {
      _snackBarService.showSnackbar(
        message: "Please fill in all required fields.",
      );
    }
  }

  @override
  void setFormStatus() {
    // You can update the form status here if needed
  }
}
