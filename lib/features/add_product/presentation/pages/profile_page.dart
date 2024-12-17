import 'package:flutter/material.dart';
import 'package:gehnaorg/features/add_product/data/models/login.dart';

class ProfilePage extends StatelessWidget {
  final Login? loginData;

  ProfilePage({Key? key, this.loginData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loginData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(child: Text('No user data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Avatar
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),

            // Profile Info Cards
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileRow(Icons.email, 'Email:', loginData?.email),
                    _buildProfileRow(
                        Icons.person, 'Identity:', loginData?.identity),
                    // _buildProfileRow(Icons.token, 'Token:', loginData?.token),
                    // SizedBox(height: 10),
                    // _buildProfileRow(Icons.admin_panel_settings,
                    //     'Admin Detail:', loginData?.adminDetail ?? 'N/A'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle "Edit Profile" action
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle "Log Out" action
                  },
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Log Out'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a row with an icon and text
  Widget _buildProfileRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          SizedBox(width: 10),
          Text(
            '$label $value',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
