import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';
import 'package:medvend/app/app.logger.dart';

class DatabaseService with ListenableServiceMixin {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final log = getLogger('DatabaseService');
  final String dbCode = 'CMGq8r4lOXQgOsN8pFV5QW4HlOe2';

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

  // Dispense medicine for a patient and update device data
  Future<void> dispenseMedicine(String patientId, String medicine) async {
    try {
      // Update patient's data to mark medicine as dispensed
      await _firebaseDatabase.ref('patients/$patientId/data/$medicine').update({
        'status': true, // set to true when dispensed
      });
      log.i("Dispensed $medicine for patient $patientId.");

      // Fetch quantity from patient's data
      DataSnapshot snapshot = await _firebaseDatabase
          .ref('patients/$patientId/data/$medicine/quantity')
          .get();
      int quantity = snapshot.value as int;

      // Update device's data path with medicine name and quantity in required format
      await _firebaseDatabase
          .ref('devices/$dbCode/data')
          .update({medicine: quantity}); // sets as medicine: quantity format
      log.i("Updated devices path with $medicine: $quantity.");

      // Reset the device's data quantity to zero after 30 seconds
      Future.delayed(Duration(seconds: 30), () async {
        await _firebaseDatabase.ref('devices/$dbCode/data').update({
          medicine: 0, // reset quantity to zero after 30 seconds
        });
        log.i("Reset $medicine quantity to zero after 30 seconds.");
      });
    } catch (e) {
      log.e("Error dispensing medicine for patient $patientId: $e");
    }
  }
}
