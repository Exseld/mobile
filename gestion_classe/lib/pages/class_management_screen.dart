import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ClassManagementScreenState createState() => ClassManagementScreenState();
}

class ClassManagementScreenState extends State<ClassManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _user = FirebaseAuth.instance.currentUser;
  String _userRole = '';

  String _classNumber = '';
  String _groupNumber = '';
  String _teacherId = '';
  List<String> _studentIds = [];
  String _dayOfWeek = 'Lundi';
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 0, minute: 0);

  List<String> _teacherIds = [];
  List<String> _teacherNames = [];
  List<DocumentSnapshot> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
    _fetchStudents();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    final userData = await _firestore.collection('utilisateurs').doc(_user?.uid).get();
    setState(() {
      _userRole = userData.get('role');
      if (_userRole == 'Enseignant') {
        _teacherId = _user!.uid;
      }
    });
  }

  Future<void> _fetchTeachers() async {
    final teachers = await _firestore.collection('utilisateurs').where('role', isEqualTo: 'Enseignant').get();
    setState(() {
      _teacherIds = teachers.docs.map((doc) => doc.id).toList();
      _teacherNames = teachers.docs.map((doc) {
        final prenom = doc.get('prenom');
        return prenom is String ? prenom : '';
      }).toList();
    });
  }

  Future<void> _fetchStudents() async {
    final students = await _firestore.collection('utilisateurs').where('role', isEqualTo: 'Etudiant').get();
    setState(() {
      _students = students.docs;
    });
  }

  Future<void> _createClass() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _firestore.collection('classes').add({
        'num_classe': _classNumber,
        'num_groupe': _groupNumber,
        'enseignant': _firestore.doc('utilisateurs/$_teacherId'),
        'etudiants': _studentIds.map((id) => _firestore.doc('utilisateurs/$id')).toList(),
        'periode': {
          'heure_debut': _startTime.format(context),
          'heure_fin': _endTime.format(context),
          'jour_semaine': _dayOfWeek,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Class Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a class number';
                }
                return null;
              },
              onSaved: (value) {
                _classNumber = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Group Number'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group number';
                }
                return null;
              },
              onSaved: (value) {
                _groupNumber = value!;
              },
            ),
            DropdownButtonFormField<String>(
              value: _teacherId.isEmpty ? null : _teacherId,
              items: _teacherIds.asMap().entries.map<DropdownMenuItem<String>>((entry) {
                int index = entry.key;
                String value = entry.value;
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(_teacherNames[index]),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _teacherId = newValue!;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final studentId = student.id;
                  final studentName = student.get('prenom');
                  return ListTile(
                    title: Text(studentName),
                    onTap: () {
                      if (!_studentIds.contains(studentId)) {
                        setState(() {
                          _studentIds.add(studentId);
                        });
                      }
                    },
                  );
                },
              ),
            ),
            DropdownButtonFormField<String>(
              value: _dayOfWeek.isEmpty ? null : _dayOfWeek,
              items: <String>['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _dayOfWeek = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (picked != null && picked != _startTime) {
                  setState(() {
                    _startTime = picked;
                  });
                }
              },
              child: const Text('Select start time'),
            ),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (picked != null && picked != _endTime) {
                  setState(() {
                    _endTime = picked;
                  });
                }
              },
              child: const Text('Select end time'),
            ),
            ElevatedButton(
              onPressed: _createClass,
              child: const Text('Create Class'),
            ),
          ],
        ),
      ),
    );
  }
}