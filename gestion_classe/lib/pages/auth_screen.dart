import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final auth = FirebaseAuth.instance;

  Future<void> _submitAuthForm(
      String email,
      String password,
      //String matricule,
      String nom,
      //String prenom,
      bool isLogin,
      ) async {
    UserCredential authResult;

    try {
      if (isLogin) {
        authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('staff')
            .doc(authResult.user!.uid)
            .set({
          'email': email,
          //'matricule': matricule,
          'nom': nom,
          //'prenom': prenom,
          'role': 'moniteur'
        });
      }
    } on FirebaseException catch (e) {
      var message = "Un erreur s'est produite.";

      if (e.message != null) {
        message = e.message!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }

    } catch (err) {
      print("Erreur non gérée : $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthFormWidget(_submitAuthForm),
    );
  }
}