import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_profile_screen.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ProfileManagementScreenState createState() => ProfileManagementScreenState();
}

class ProfileManagementScreenState extends State<ProfileManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final userData = await _firestore.collection('utilisateurs').doc(_user?.uid).get();
    setState(() {
      _userRole = userData.get('role');
    });
  }

  Stream<QuerySnapshot> getUsersStream() {
    if (_userRole == 'Enseignant') {
      return _firestore.collection('utilisateurs').where('role', isEqualTo: 'Etudiant').snapshots();
    } else {
      return _firestore.collection('utilisateurs').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final users = snapshot.data!.docs;
          List<Widget> userWidgets = [];

          for (var user in users) {
            final matricule = user.get('matricule');
            final email = user.get('email');

            userWidgets.add(
              ListTile(
                title: Text(matricule),
                subtitle: Text(email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfileScreen(user: user, userRole: _userRole),
                    ),
                  );
                },
              ),
            );
          }

          return ListView(
            children: userWidgets,
          );
        },
      ),
    );
  }
}