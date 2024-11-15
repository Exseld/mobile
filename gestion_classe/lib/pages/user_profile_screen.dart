import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreen extends StatefulWidget {
  final DocumentSnapshot user;
  final String userRole;

  const UserProfileScreen({super.key, required this.user, required this.userRole});

  @override
  UserProfileScreenState createState() => UserProfileScreenState();
}

class UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _matricule = '';
  String _nom = '';
  String _prenom = '';
  String _role = '';

  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _emailController.text = widget.user.get('email');
      _matriculeController.text = widget.user.get('matricule');
      _nomController.text = widget.user.get('nom');
      _prenomController.text = widget.user.get('prenom');
      _roleController.text = widget.user.get('role');
    });
  }

  void _saveForm() {
    final isValid = _formKey.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _formKey.currentState?.save();
    _firestore.collection('utilisateurs').doc(widget.user.id).update({
      'email': _email,
      'matricule': _matricule,
      'nom': _nom,
      'prenom': _prenom,
      'role': _role,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
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
                readOnly: widget.userRole == 'Enseignant',
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
                readOnly: widget.userRole == 'Enseignant',
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
                readOnly: widget.userRole == 'Enseignant',
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
                readOnly: widget.userRole == 'Enseignant',
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
              if (widget.userRole == 'Administrateur')
                DropdownButtonFormField(
                  value: _roleController.text,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['Etudiant', 'Enseignant', 'Administrateur']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _roleController.text = value.toString();
                    });
                  },
                  onSaved: (value) {
                    _role = value.toString();
                  },
                ),
              if (widget.userRole == 'Administrateur')
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