import 'package:flutter/material.dart';

//This screen shows reccomended technicians
class TechnicianMatchScreen extends StatelessWidget {
  const TechnicianMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar
      (title: const Text("Technician Match")
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            //Technician card
            Card(
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("John Silva"),
                subtitle: const Text("Washing Machine Specialist."),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Contact"),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card (
              elevation: 3,
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Nimal Perera"),
                subtitle: const Text("Home Application Technician."),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Contact"),
                ),
              ),