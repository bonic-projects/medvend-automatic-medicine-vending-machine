import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'doctor_viewmodel.dart';
import 'package:medvend/models/app_user.dart';

class DoctorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DoctorViewModel>.reactive(
      viewModelBuilder: () => DoctorViewModel(),
      onModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Doctor's Dashboard"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: viewModel.logout, // Logout button
              tooltip: 'Logout',
            ),
          ],
        ),
        body: viewModel.isBusy
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: viewModel.patients.length,
                  itemBuilder: (context, index) {
                    AppUser patient = viewModel.patients[index];
                    String patientId = patient.id!;

                    return Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12.0),
                        title: Text(
                          patient.fullName ?? "Unnamed Patient",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.email ?? "No email"),
                            SizedBox(height: 8.0),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              value: viewModel
                                  .selectedMedicineForPatient[patientId],
                              hint: Text("Select Medicine"),
                              items: viewModel.predefinedMedicines
                                  .map((medicine) => DropdownMenuItem(
                                        value: medicine,
                                        child: Text(medicine),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                viewModel.setSelectedMedicineForPatient(
                                    patientId, value);
                              },
                            ),
                            SizedBox(height: 8.0),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              value: viewModel
                                      .selectedQuantityForPatient[patientId] ??
                                  1,
                              hint: Text("Select Quantity"),
                              items: viewModel.quantities
                                  .map((quantity) => DropdownMenuItem(
                                        value: quantity,
                                        child: Text(quantity.toString()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                viewModel.setSelectedQuantityForPatient(
                                    patientId, value!);
                              },
                            ),
                            SizedBox(height: 8.0),
                            ElevatedButton(
                              onPressed: viewModel.selectedMedicineForPatient[
                                          patientId] !=
                                      null
                                  ? () {
                                      viewModel.prescribeMedicine(patientId);
                                    }
                                  : null,
                              child: Text("Prescribe"),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.video_call, color: Colors.blue),
                          onPressed: () {
                            viewModel.startVideoCall(patientId);
                          },
                          tooltip: 'Start Video Call',
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
