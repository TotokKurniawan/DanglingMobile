import 'package:damping/screen/profil/component/updateaccount.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:damping/service/sharedProvider.dart';

class MyAccountScreen extends StatelessWidget {
  Widget _buildProfileItem(String label, String? text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: Colors.indigoAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label: ${text ?? 'Not available'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<Sharedprovider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.indigoAccent.shade100,
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),
            _buildProfileItem('Name', sharedProvider.nama),
            _buildProfileItem('Email', sharedProvider.email),
            _buildProfileItem('Password', sharedProvider.password),
            _buildProfileItem('Role', sharedProvider.role),
            const SizedBox(height: 20),

            // Tombol untuk membuka halaman UpdateProfileForm
            ElevatedButton(
              onPressed: () {
                // Navigasi ke halaman UpdateProfileForm
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateProfileForm()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              child: const Text(
                'Update Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
