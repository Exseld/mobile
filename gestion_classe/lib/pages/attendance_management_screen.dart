import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_classe/pages/user_profile_screen.dart';
import 'package:intl/intl.dart';

class AttendanceManagementScreen extends StatefulWidget {
  final int selectedDay;
  final String selectedDate;

  const AttendanceManagementScreen({super.key, required this.selectedDay, required this.selectedDate});

  @override
  AttendanceManagementScreenState createState() => AttendanceManagementScreenState();
}

class AttendanceManagementScreenState extends State<AttendanceManagementScreen> {
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

  Stream<QuerySnapshot> _fetchClasses() {
    String dayOfWeek = '';
    switch (widget.selectedDay) {
      case 2:
        dayOfWeek = 'Lundi';
        break;
      case 3:
        dayOfWeek = 'Mardi';
        break;
      case 4:
        dayOfWeek = 'Mercredi';
        break;
      case 5:
        dayOfWeek = 'Jeudi';
        break;
      case 6:
        dayOfWeek = 'Vendredi';
        break;
      default:
        dayOfWeek = '';
    }

    if (_userRole == 'Enseignant') {
      return _firestore.collection('classes')
        .where("periode.jour_semaine", isEqualTo: dayOfWeek)
        .where("enseignant", isEqualTo: _firestore.doc('utilisateurs/${_user?.uid}'))
        .snapshots();
    } else {
      return _firestore.collection('classes')
        .where("periode.jour_semaine", isEqualTo: dayOfWeek)
        .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchClasses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final classes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassStudentsScreen(
                        classId: classes[index].id,
                        userRole: _userRole,
                        selectedDate: widget.selectedDate,),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(classes[index].get('num_classe')),
                  subtitle: Text(classes[index].get('num_groupe')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ClassStudentsScreen extends StatelessWidget {
  final String classId;
  final String selectedDate;
  final String userRole;

  const ClassStudentsScreen({super.key, required this.classId, required this.userRole, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Students'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('classes').doc(classId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final classDoc = snapshot.data!;
          final studentRefs = classDoc.get('etudiants') as List;
          return FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(studentRefs.map((ref) => ref.get())),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error: ${snapshot.error}');
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final students = snapshot.data!;
              return ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(students[index].id),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) async {
                      // Fetch the class document
                      final classDoc = await firestore.collection('classes').doc(classId).get();

                      // Get the heure_debut from the periode field
                      final heure_debut = classDoc.get('periode')['heure_debut'];

                      // Parse the selectedDate into DateTime object
                      final selectedDateTime = DateTime.parse(selectedDate);

                      // Parse the heure_debut into DateTime object
                      final heureDebutTime = TimeOfDay.fromDateTime(DateFormat("H:mm").parse(heure_debut));

                      // Combine the selectedDate and heure_debut
                      final combinedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          heureDebutTime.hour,
                          heureDebutTime.minute
                      );

                      await firestore.collection('presences').add({
                        'classe': firestore.doc('classes/$classId'),
                        'date': Timestamp.fromDate(combinedDateTime),
                        'etudiant': students[index].reference,
                        'statut': 'absent',
                        'nb_heures': 2,
                      });
                    },
                    background: Container(color: Colors.red),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfileScreen(user: students[index], userRole: 'Etudiant'),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(students[index].get('nom')),
                        subtitle: Text(students[index].get('prenom')),
                      ),
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