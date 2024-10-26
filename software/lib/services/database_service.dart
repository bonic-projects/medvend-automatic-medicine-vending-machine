import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';
import 'package:medvend/app/app.logger.dart';

class DatabaseService with ListenableServiceMixin {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final log = getLogger('DatabaseService');

  // Fetch prescribed medicines for a specific patient
  Future<Map<String, dynamic>> fetchPrescribedMedicines(
      String patientId) async {
    try {
      DataSnapshot snapshot =
          await _firebaseDatabase.ref('patients/$patientId/data').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        log.w("No prescribed medicines found for patient $patientId.");
        return {};
      }
    } catch (e) {
      log.e("Error fetching prescribed medicines: $e");
      return {};
    }
  }

  // Update medicine quantity for a specific patient
  Future<void> updateMedicineQuantityForPatient(
      String patientId, String medicine, int newQuantity) async {
    try {
      await _firebaseDatabase.ref('patients/$patientId/data/$medicine').update({
        'quantity': newQuantity,
      });
      log.i(
          "Updated $medicine quantity to $newQuantity for patient $patientId.");
    } catch (e) {
      log.e("Error updating medicine quantity for patient $patientId: $e");
    }
  }

  // Prescribe medicine for a patient with doctor name
  Future<void> prescribeMedicine(String patientId, String medicine,
      int quantity, String doctorName) async {
    try {
      await _firebaseDatabase.ref('patients/$patientId/data/$medicine').set({
        'quantity': quantity,
        'doctorName': doctorName, // Include doctor's name
        'status': false, // default to false until it’s dispensed
      });
      log.i(
          "Prescribed $medicine with quantity $quantity for patient $patientId by Dr. $doctorName.");
    } catch (e) {
      log.e("Error prescribing medicine: $e");
    }
  }

  // Dispense medicine for a patient
  Future<void> dispenseMedicine(String patientId, String medicine) async {
    try {
      await _firebaseDatabase.ref('patients/$patientId/data/$medicine').update({
        'status': true, // set to true when dispensed
      });
      log.i("Dispensed $medicine for patient $patientId.");

      // Reset the status after 10 seconds
      Future.delayed(Duration(seconds: 10), () async {
        await _firebaseDatabase
            .ref('patients/$patientId/data/$medicine')
            .update({
          'status': false, // reset to false after dispensing
        });
        log.i(
            "Reset $medicine status to false for patient $patientId after 10 seconds.");
      });
    } catch (e) {
      log.e("Error dispensing medicine for patient $patientId: $e");
    }
  }
}
