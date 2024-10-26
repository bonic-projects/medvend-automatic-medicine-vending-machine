import 'package:medvend/services/database_service.dart';
import 'package:medvend/services/firestore_service.dart';
import 'package:medvend/services/user_service.dart';
import 'package:medvend/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:medvend/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:medvend/ui/views/home/home_view.dart';
import 'package:medvend/ui/views/startup/startup_view.dart';
import 'package:medvend/ui/views/videocall/videocall_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_firebase_auth/stacked_firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:medvend/ui/views/login_register/login_register_view.dart';
import 'package:medvend/ui/views/login/login_view.dart';
import 'package:medvend/ui/views/register/register_view.dart';

import 'package:medvend/services/firebase_service.dart';
import 'package:medvend/ui/views/doctor/doctor_view.dart';
import 'package:medvend/ui/views/patient/patient_view.dart';

// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginRegisterView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: RegisterView),
    MaterialRoute(page: DoctorView),

    MaterialRoute(page: PatientView),
    MaterialRoute(page: VideoCallView),

// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),

    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: FirebaseAuthService),
    LazySingleton(classType: FirestoreService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: DatabaseService),
    LazySingleton(classType: FirebaseAuthenticationService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
