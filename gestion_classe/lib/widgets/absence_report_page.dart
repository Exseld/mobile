import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbsenceReportPage extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  AbsenceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport d\'absence'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('classes').where('enseignant', isEqualTo: firestore.doc('utilisateurs/$uid')).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final classes = snapshot.data?.docs;
          return ListView.builder(
            itemCount: classes?.length,
            itemBuilder: (context, index) {
              final classDoc = classes?[index];
              return ListTile(
                title: Text(classDoc?.get('num_classe')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassStudentsPage(classDoc: classDoc),
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

class ClassStudentsPage extends StatelessWidget {
  final DocumentSnapshot? classDoc;

  const ClassStudentsPage({super.key, required this.classDoc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Étudiants de ${classDoc?.get('num_groupe')}'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            print(snapshot.error);
            return const CircularProgressIndicator();
          }

          final students = snapshot.data;
          return ListView.builder(
            itemCount: students?.length,
            itemBuilder: (context, index) {
              final studentDoc = students?[index];
              return ListTile(
                title: Text(studentDoc?.get('prenom')),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAbsencesPage(studentDoc: studentDoc, classDoc: classDoc),
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

  Future<List<DocumentSnapshot>> fetchStudents() async {
    final etudiantsRefs = (classDoc?.get('etudiants') as List).cast<DocumentReference<Object?>>();

    final students = <DocumentSnapshot>[];
    for (var i = 0; i < etudiantsRefs.length; i += 10) {
      final end = i + 10 < etudiantsRefs.length ? i + 10 : etudiantsRefs.length;
      final batch = etudiantsRefs.sublist(i, end);
      final snapshot = await FirebaseFirestore.instance.collection('utilisateurs').where(FieldPath.documentId, whereIn: batch.map((ref) => ref.id).toList()).get();
      students.addAll(snapshot.docs);
    }

    return students;
  }
}

class StudentAbsencesPage extends StatelessWidget {
  final DocumentSnapshot? studentDoc;
  final DocumentSnapshot? classDoc;

  const StudentAbsencesPage({super.key, required this.studentDoc, required this.classDoc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Absences de ${studentDoc?.get('prenom')}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('presences').where('etudiant', isEqualTo: studentDoc?.reference).where('classe', isEqualTo: classDoc?.reference).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final presences = snapshot.data?.docs;
          return ListView.builder(
            itemCount: presences?.length,
            itemBuilder: (context, index) {
              final presenceDoc = presences?[index];
              return ListTile(
                title: Text(presenceDoc!.get('date').toDate().toString()),
                subtitle: Text('Heures d\'absence: ${presenceDoc.get('nb_heures')}'),
              );
            },
          );
        },
      ),
    );
  }
}