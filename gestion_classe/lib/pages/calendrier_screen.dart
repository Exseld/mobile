import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_classe/pages/class_management_screen.dart';
import 'package:gestion_classe/pages/enseignant_class_management_screen.dart';
import 'package:gestion_classe/pages/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/absence_report_page.dart';
import 'attendance_management_screen.dart';
import 'profile_management_screen.dart';

import '../model/CalendarDay.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}


class CalendarScreenState extends State<CalendarScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  String _userRole = '';

  Map<String, CalendarDay> _calendarDays = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchCalendarData();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final userData = await _firestore.collection('utilisateurs').doc(_user?.uid).get();
        setState(() {
          _userRole = userData.get('role'); // Provide a default value if 'role' is not found
        });
    } catch (e) {
      setState(() {
        _userRole = 'Error'; // Provide a default value in case of an error
      });
      print('Error fetching user role: $e');
    }
  }

  Future<void> _fetchCalendarData() async {
    try {
      final response = await http.get(Uri.parse('https://us-central1-cegep-al.cloudfunctions.net/calendrier'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _calendarDays = data.map<String, CalendarDay>((key, value) {
            return MapEntry(key, CalendarDay.fromJson(value as Map<String, dynamic>));
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load data. Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
      ),
      itemCount: _calendarDays.length,
      itemBuilder: (context, index) {
        String date = _calendarDays.keys.elementAt(index);
        CalendarDay day = _calendarDays[date]!;
        return GestureDetector(
          onTap: () {
            if (_userRole == 'Enseignant' || _userRole == 'Administrateur') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceManagementScreen(
                    selectedDay: day.jourSemaine,
                    selectedDate: date,
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              color: _getDayColor(day.special),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    _getDayOfWeek(day.jourSemaine), // Display the day of the week
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('d').format(DateTime.parse(date)), // Display only the day
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Text(_getSpecialText(day.special)),
                ),
                if (day.semaine != null)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('${day.semaine}'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDayOfWeek(int jourSemaine) {
    switch (jourSemaine) {
      case 2:
        return 'Lundi';
      case 3:
        return 'Mardi';
      case 4:
        return 'Mercredi';
      case 5:
        return 'Jeudi';
      case 6:
        return 'Vendredi';
      default:
        return '';
    }
  }
  Color _getDayColor(String special) {
    switch (special) {
      case 'TP':
        return Colors.green;
      case 'C':
        return Colors.red;
      case 'A':
        return Colors.blue;
      case 'EUF':
        return Colors.purple;
      case 'EC':
        return Colors.yellow;
      case 'PO':
        return Colors.orange;
      case 'JM':
        return Colors.brown;
      default:
        return Colors.white;
    }
  }

  String _getSpecialText(String special) {
    switch (special) {
      case 'TP':
        return 'TP';
      case 'C':
        return 'C';
      case 'A':
        return 'A';
      case 'EUF':
        return 'EUF';
      case 'EC':
        return 'EC';
      case 'PO':
        return 'PO';
      case 'JM':
        return 'JM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          if (_userRole == 'Enseignant' || _userRole == 'Administrateur')
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileManagementScreen(),
                  ),
                );
              },
            ),
          if (_userRole == 'Administrateur')
            IconButton(
              icon: const Icon(Icons.class_),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClassManagementScreen(),
                  ),
                );
              },
            ),
          if (_userRole == 'Enseignant') ...[
            IconButton(
              icon: const Icon(Icons.class_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EnseignantClassManagementScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.block),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AbsenceReportPage(),
                  ),
                );
              },
            ),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _buildCalendarGrid(),
    );
  }
}
