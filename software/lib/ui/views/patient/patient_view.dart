import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'patient_viewmodel.dart';

class PatientView extends StatelessWidget {
  final String patientId;

  const PatientView({Key? key, required this.patientId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PatientViewModel>.reactive(
      viewModelBuilder: () => PatientViewModel(),
      onModelReady: (viewModel) => viewModel.initialize(patientId),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text("Patient Dashboard"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: viewModel.logout,
            ),
          ],
        ),
        body: viewModel.isBusy
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prescribed Medicines",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: viewModel.prescribedMedicines.isEmpty
                          ? Center(child: Text("No prescribed medicines"))
                          : ListView.builder(
                              itemCount: viewModel.prescribedMedicines.length,
                              itemBuilder: (context, index) {
                                String medicineName = viewModel
                                    .prescribedMedicines.keys
                                    .elementAt(index);
                                var medicineData =
                                    viewModel.prescribedMedicines[medicineName];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  child: ListTile(
                                    title: Text(medicineName),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Prescribed by Doctor: ${medicineData['doctorName'] ?? 'Unknown'}"),
                                        Text(
                                            "Prescribed Quantity: ${medicineData['quantity']}"),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditQuantityDialog(
                                                context,
                                                viewModel,
                                                medicineName,
                                                medicineData['quantity']);
                                          },
                                        ),
                                        ElevatedButton(
                                          onPressed: () => viewModel
                                              .dispenseMedicine(medicineName),
                                          child: Text("Dispense"),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: viewModel.startVideoCall,
                        child: Text("Join Video Call"),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context, PatientViewModel viewModel,
      String medicineName, int maxQuantity) {
    final TextEditingController quantityController =
        TextEditingController(text: maxQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Quantity for $medicineName"),
        content: TextField(
          controller: quantityController,
          decoration: InputDecoration(labelText: "Enter new quantity"),
          keyboardType: TextInputType.number,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              int? newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity <= maxQuantity) {
                viewModel.updateMedicineQuantity(medicineName, newQuantity);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Invalid quantity. Must be less than or equal to $maxQuantity."),
                  ),
                );
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}
