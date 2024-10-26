import 'package:stacked/stacked.dart';

class PatientService with ListenableServiceMixin {
  String? _currentPatientId;

  String? get currentPatientId => _currentPatientId;

  void setPatientId(String patientId) {
    _currentPatientId = patientId;
    notifyListeners();
  }
}
