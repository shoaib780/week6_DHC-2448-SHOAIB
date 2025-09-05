import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task3/screen/todo_list.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data() as Map<String, dynamic>;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  void _goToTodoScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TodoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text('No user data found'))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Avatar
            CircleAvatar(
              backgroundColor: Colors.blue[700],
              radius: 50,
              child: Text(
                _userData!['name']?[0] ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // User Name
            Text(
              _userData!['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // User Email
            Text(
              _userData!['email'] ?? 'No Email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 30),

            // User Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow('User ID', _userData!['userId'] ?? 'N/A'),
                    const Divider(),
                    _buildDetailRow('Member Since',
                        _userData!['createdAt'] != null
                            ? _userData!['createdAt'].toDate().toString().split(' ')[0]
                            : 'N/A'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Go to Tasks Button
                ElevatedButton(
                  onPressed: _goToTodoScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.task, size: 20),
                      SizedBox(width: 8),
                      Text('My Tasks'),
                    ],
                  ),
                ),

                // Logout Button
                ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Additional Options
            Expanded(
              child: ListView(
                children: [
                  _buildMenuOption(Icons.settings, 'Settings', () {}),
                  _buildMenuOption(Icons.help, 'Help & Support', () {}),
                  _buildMenuOption(Icons.privacy_tip, 'Privacy Policy', () {}),
                  _buildMenuOption(Icons.star, 'Rate App', () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}