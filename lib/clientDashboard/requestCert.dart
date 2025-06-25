import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Requestcert extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Certificate Issuance"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // Retrieve the input data
                    String name = nameController.text.trim();
                    String date = dateController.text.trim();
                    String title = titleController.text.trim();

                    // Validation: Ensure all fields are filled
                    if (name.isNotEmpty && date.isNotEmpty && title.isNotEmpty) {
                      try {
                        // Send data to Firestore
                        await firestore.collection('requestCert').add({
                          'name': name,
                          'date': date,
                          'title': title,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        // Notify success
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Data saved successfully!")),
                        );

                        // Clear input fields
                        nameController.clear();
                        dateController.clear();
                        titleController.clear();
                      } catch (e) {
                        // Handle Firestore errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to save data: $e")),
                        );
                      }
                    } else {
                      // Notify user to fill in all fields
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill out all fields!")),
                      );
                    }
                  },
                  child: Text("Send"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
