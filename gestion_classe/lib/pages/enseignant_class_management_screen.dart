import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnseignantClassManagementScreen extends StatefulWidget {
  const EnseignantClassManagementScreen({super.key});

  @override
  EnseignantClassManagementScreenState createState() => EnseignantClassManagementScreenState();
}

class EnseignantClassManagementScreenState extends State<EnseignantClassManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enseignant Class Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('classes').where('enseignant', isEqualTo: _firestore.doc('utilisateurs/${_user?.uid}')).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final classes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classDoc = classes[index];
              final classNumber = classDoc.get('num_classe');
              final groupNumber = classDoc.get('num_groupe');

              return ListTile(
                title: Text('Class $classNumber Group $groupNumber'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDetailScreen(classDoc: classDoc),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
class ClassDetailScreen extends StatefulWidget {
  final DocumentSnapshot classDoc;

  const ClassDetailScreen({super.key, required this.classDoc});

  @override
  ClassDetailScreenState createState() => ClassDetailScreenState();
}

class ClassDetailScreenState extends State<ClassDetailScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 0, minute: 0);
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();

  String _dayOfWeek = 'Lundi';
  List<DocumentSnapshot> _students = [];
  List<String> _studentIds = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _startTimeController.text = widget.classDoc.get('periode')['heure_debut'];
    _endTimeController.text = widget.classDoc.get('periode')['heure_fin'];
  }

  Future<void> _fetchStudents() async {
    // Fetch the list of students who are already in the class
    List<DocumentReference> existingStudentRefs = List<DocumentReference>.from(widget.classDoc.get('etudiants') ?? []);
    List<String> existingStudentIds = existingStudentRefs.map((ref) => ref.id).toList();

    // Fetch all students
    final students = await _firestore.collection('utilisateurs').where('role', isEqualTo: 'Etudiant').get();

    // Exclude the students who are already in the class
    setState(() {
      _students = students.docs.where((student) => !existingStudentIds.contains(student.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Detail'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: 'Start Time'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a start time';
                }
                return null;
              },
              onSaved: (value) {
                final timeOfDay = TimeOfDay.fromDateTime(DateFormat("h:mm a").parse(value!));
                _startTime = timeOfDay;
              },
            ),
            TextFormField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: 'End Time'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an end time';
                }
                return null;
              },
              onSaved: (value) {
                final timeOfDay = TimeOfDay.fromDateTime(DateFormat("h:mm a").parse(value!));
                _endTime = timeOfDay;
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  final studentId = student.id;
                  final studentName = student.get('prenom');

                  // If the student is already in the class, do not show them in the list
                  if (_studentIds.contains(studentId)) {
                    return Container(); // Return an empty container
                  }

                  return ListTile(
                    title: Text(studentName),
                    onTap: () {
                      setState(() {
                        _studentIds.add(studentId);
                      });
                    },
                  );
                },
              ),
            ),
            DropdownButtonFormField<String>(
              value: _dayOfWeek,
              items: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi'].map<DropdownMenuItem<String>>((String value) {
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
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Update the class document with the new periode and etudiants
                  await widget.classDoc.reference.update({
                    'periode': {
                      'heure_debut': '${_startTime.hour}:${_startTime.minute.toString().padLeft(2, '0')}',
                      'heure_fin': '${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                      'jour_semaine': _dayOfWeek
                    },
                    'etudiants': _studentIds.map((id) => _firestore.doc('utilisateurs/$id')).toList(),
                  });
                }
              },
              child: const Text('Update Class'),
            ),
          ],
        ),
      ),
    );
  }
}