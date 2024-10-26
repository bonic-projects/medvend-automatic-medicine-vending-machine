import 'package:medvend/app/app.locator.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:medvend/app/app.router.dart';
import 'package:medvend/services/database_service.dart';
import 'package:medvend/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class PatientViewModel extends BaseViewModel {
  final log = getLogger('PatientViewModel');
  final _databaseService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();

  Map<String, dynamic> prescribedMedicines = {};
  String? patientId;

  Future<void> initialize(String id) async {
    setBusy(true);
    patientId = id;

    try {
      prescribedMedicines =
          await _databaseService.fetchPrescribedMedicines(patientId!);
      if (prescribedMedicines.isNotEmpty) {
        log.i("Fetched prescribed medicines for patient $patientId.");
      } else {
        log.w("No prescribed medicines found for patient $patientId.");
      }
      notifyListeners();
    } catch (e) {
      log.e("Error fetching prescribed medicines: $e");
    } finally {
      setBusy(false);
    }
  }

  void updateMedicineQuantity(String medicine, int newQuantity) async {
    if (patientId == null || prescribedMedicines[medicine] == null) {
      log.e("Cannot update medicine quantity for null patient or medicine.");
      return;
    }

    try {
      int prescribedQuantity = prescribedMedicines[medicine]['quantity'];
      if (newQuantity <= prescribedQuantity) {
        await _databaseService.updateMedicineQuantityForPatient(
            patientId!, medicine, newQuantity);
        log.i(
            "Updated $medicine quantity to $newQuantity for patient $patientId.");
        prescribedMedicines[medicine]['quantity'] = newQuantity;
        notifyListeners();
      } else {
        log.w("Cannot update $medicine quantity beyond prescribed amount.");
      }
    } catch (e) {
      log.e("Error updating medicine quantity: $e");
    }
  }

  Future<void> dispenseMedicine(String medicine) async {
    if (patientId == null || prescribedMedicines[medicine] == null) {
      log.e("Cannot dispense medicine for null patient or medicine.");
      return;
    }

    try {
      await _databaseService.dispenseMedicine(patientId!, medicine);
      log.i("Dispensed $medicine for patient $patientId.");
    } catch (e) {
      log.e("Error dispensing medicine: $e");
    }
  }

  Future<void> startVideoCall() async {
    log.i("Starting video call for patient $patientId.");
    _navigationService
        .navigateTo(
      Routes.videoCallView,
      arguments: VideoCallViewArguments(
          patientId: patientId!,
          roomName: "Doctor-Patient Room",
          isDoctor: false),
    )
        ?.catchError((error) {
      log.e("Failed to start video call: $error");
    });
  }

  Future<void> logout() async {
    try {
      await _userService.logout();
      _navigationService.replaceWith(Routes.loginView);
      log.i("Patient logged out.");
    } catch (e) {
      log.e("Error during logout: $e");
    }
  }
}
