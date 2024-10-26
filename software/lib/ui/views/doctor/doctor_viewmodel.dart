import 'package:medvend/app/app.locator.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:medvend/app/app.router.dart';
import 'package:medvend/models/app_user.dart';
import 'package:medvend/services/database_service.dart';
import 'package:medvend/services/user_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DoctorViewModel extends BaseViewModel {
  final log = getLogger('DoctorViewModel');
  final _databaseService = locator<DatabaseService>();
  final _userService = locator<UserService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  List<AppUser> patients = [];
  List<String> predefinedMedicines = [
    'Paracetamol',
    'Amoxicillin',
    'Ibuprofen'
  ];
  List<int> quantities = List.generate(10, (index) => index + 1);

  // Store selected medicine and quantity for each patient
  Map<String, String?> selectedMedicineForPatient = {};
  Map<String, int> selectedQuantityForPatient = {};

  Future<void> initialize() async {
    setBusy(true);
    try {
      patients = await _userService.getPatients();
      log.i("Fetched patients for the doctor.");
    } catch (e) {
      log.e("Error fetching patients: $e");
    } finally {
      setBusy(false);
    }
  }

  void prescribeMedicine(String patientId) {
    String? selectedMedicine = selectedMedicineForPatient[patientId];
    int selectedQuantity = selectedQuantityForPatient[patientId] ?? 1;

    if (selectedMedicine != null) {
      String? doctorName = _userService.user?.fullName ?? "Unknown Doctor";

      _databaseService
          .prescribeMedicine(
              patientId, selectedMedicine, selectedQuantity, doctorName)
          .then((_) {
        log.i(
            "Prescribed $selectedMedicine to $patientId with quantity $selectedQuantity by Dr. $doctorName.");

        _dialogService.showDialog(
          title: "Prescription Completed",
          description:
              "You have prescribed $selectedMedicine to the patient with a quantity of $selectedQuantity.",
          buttonTitle: "OK",
        );
      }).catchError((error) {
        log.e("Failed to prescribe medicine: $error");
        _dialogService.showDialog(
          title: "Error",
          description: "An error occurred while prescribing the medicine.",
          buttonTitle: "OK",
        );
      });
    } else {
      log.e("No medicine selected to prescribe.");
      _dialogService.showDialog(
        title: "No Medicine Selected",
        description: "Please select a medicine to prescribe.",
        buttonTitle: "OK",
      );
    }
  }

  void setSelectedMedicineForPatient(String patientId, String? medicine) {
    selectedMedicineForPatient[patientId] = medicine;
    notifyListeners();
  }

  void setSelectedQuantityForPatient(String patientId, int quantity) {
    selectedQuantityForPatient[patientId] = quantity;
    notifyListeners();
  }

  Future<void> startVideoCall(String patientId) async {
    log.i("Starting video call for patient $patientId.");
    _navigationService
        .navigateTo(
      Routes.videoCallView,
      arguments: VideoCallViewArguments(
        patientId: patientId,
        roomName: "Doctor-Patient Room",
        isDoctor: true,
      ),
    )
        ?.catchError((error) {
      log.e("Failed to start video call: $error");
    });
  }

  void logout() {
    _userService.logout().then((_) {
      _navigationService.replaceWith(Routes.loginView);
      log.i("Logged out.");
    }).catchError((error) {
      log.e("Logout failed: $error");
    });
  }
}
