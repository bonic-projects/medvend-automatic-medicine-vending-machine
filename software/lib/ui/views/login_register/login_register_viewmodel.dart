import 'package:medvend/app/app.locator.dart';

import 'package:medvend/app/app.router.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';

class LoginRegisterViewModel extends BaseViewModel {
  // final log = getLogger('LoginRegisterViewModel');

  // final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  void openLoginView() {
    _navigationService.navigateToLoginView();
  }

  void openRegisterView() {
    _navigationService.navigateToRegisterView();
  }
}
