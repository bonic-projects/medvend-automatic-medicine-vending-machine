import 'package:medvend/app/app.locator.dart';
import 'package:medvend/app/app.router.dart';
import 'package:medvend/services/database_service.dart';
import 'package:stacked/stacked.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:medvend/services/user_service.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final log = getLogger('StartupViewModel');
  final _navigationService = locator<NavigationService>();
  final _userService = locator<UserService>();

  Future runStartupLogic() async {
    log.i('Running startup logic');

    // Check if the user is logged in
    if (_userService.hasLoggedInUser) {
      await _userService.fetchUser();

      if (_userService.user != null) {
        String userRole = _userService.user!.userRole;

        if (userRole == 'Doctor') {
          _navigationService.replaceWith(Routes.doctorView);
        } else if (userRole == 'Patient') {
          _navigationService.replaceWith(
            Routes.patientView,
            arguments: PatientViewArguments(
              patientId: _userService.user!.id,
            ),
          );
        } else {
          _navigationService.replaceWith(Routes.loginRegisterView);
        }
      } else {
        _navigationService.replaceWith(Routes.loginRegisterView);
      }
    } else {
      _navigationService.replaceWith(Routes.loginRegisterView);
    }
  }
}
