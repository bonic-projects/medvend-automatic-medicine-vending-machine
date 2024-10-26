import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:medvend/ui/views/login_register/login_register_viewmodel.dart';
import 'package:medvend/widgets/login-register.dart';

import 'package:stacked/stacked.dart';

class LoginRegisterView extends StackedView<LoginRegisterViewModel> {
  const LoginRegisterView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginRegisterViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 15),
                  child: Image.asset(
                    'assets/medvent.png',
                    height: 500,
                  ),
                ),
                LoginRegisterWidget(
                  onLogin: viewModel.openLoginView,
                  onRegister: viewModel.openRegisterView,
                  loginText: "Existing Doctor",
                  registerText: "Doctor registration",
                ),
              ],
            ),
          ),
        ));
  }

  @override
  LoginRegisterViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginRegisterViewModel();
}
