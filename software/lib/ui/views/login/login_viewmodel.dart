import 'package:medvend/app/app.locator.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:medvend/app/app.router.dart';
import 'package:medvend/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'login_view.form.dart';

class LoginViewModel extends FormViewModel {
  final log = getLogger('LoginViewModel');
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _snackBarService = locator<SnackbarService>();

  // Called when the view model is ready
  void onModelReady() {
    // You can initialize any values here if needed
  }

  // Authentication logic for logging in
  Future<void> authenticateUser() async {
    // Trigger form validation before performing the login
    validateForm();

    // Proceed only if the form is valid
    if (isFormValid) {
      setBusy(true); // Show loading indicator
      log.i("Attempting to log in user with email: $emailValue");

      String? errorMessage = await _userService.loginWithEmailAndPassword(
        emailValue!,
        passwordValue!,
      );

      if (errorMessage != null) {
        _snackBarService.showSnackbar(message: errorMessage);
      } else {
        log.i("User logged in successfully. Fetching user profile...");
        await _userService.fetchUser();

        // Navigate based on user role
        if (_userService.user!.userRole == "Patient") {
          // Navigate to PatientView with PatientViewArguments (pass patientId)
          _navigationService.pushNamedAndRemoveUntil(
            Routes.patientView,
            arguments: PatientViewArguments(
                patientId: _userService.user!.id), // Pass patientId here
          );
        } else if (_userService.user!.userRole == "Doctor") {
          _navigationService.pushNamedAndRemoveUntil(Routes.doctorView);
        } else {
          _snackBarService.showSnackbar(message: "Unknown user role.");
        }
      }

      setBusy(false); // Hide loading indicator
    } else {
      _snackBarService.showSnackbar(
        message: "Please enter valid email and password.",
      );
    }
  }

  @override
  void setFormStatus() {
    // You can update the form status here if needed
  }
}
