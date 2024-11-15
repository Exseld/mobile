import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _matricule = '';
  String _nom = '';
  String _prenom = '';

  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await _firestore.collection('utilisateurs').doc(_user?.uid).get();
    setState(() {
      _emailController.text = userData.get('email');
      _matriculeController.text = userData.get('matricule');
      _nomController.text = userData.get('nom');
      _prenomController.text = userData.get('prenom');
    });
  }

  void _saveForm() {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
    _firestore.collection('utilisateurs').doc(_user?.uid).update({
      'email': _email,
      'matricule': _matricule,
      'nom': _nom,
      'prenom': _prenom,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              TextFormField(
                controller: _matriculeController,
                decoration: const InputDecoration(labelText: 'Matricule'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a matricule.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _matricule = value ?? '';
                },
              ),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a nom.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nom = value ?? '';
                },
              ),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(labelText: 'Prenom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a prenom.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _prenom = value ?? '';
                },
              ),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}