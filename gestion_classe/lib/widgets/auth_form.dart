import 'package:flutter/material.dart';

class AuthFormWidget extends StatefulWidget {
  final Future<void> Function(
      String email,
      String password,
//      String matricule,
      String nom,
//      String prenom,
      bool isLogin,
      ) _submitForm;
  const AuthFormWidget(this._submitForm, {super.key});

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _key = GlobalKey<FormState>();
  var _isLogin = true;
  String _userEmail = "";
  String _userPassword = "";
//  String _userMatricule = "";
  String _userNom = "";
//  String _userPrenom = "";

  void _submit() async {
    final isValid = _key.currentState?.validate();
    FocusScope.of(context).unfocus();

    if (isValid ?? false) {
      _key.currentState?.save();

      await widget._submitForm(
          _userEmail.trim(),
          _userPassword.trim(),
//          _userMatricule.trim(),
          _userNom.trim(),
//          _userPrenom.trim(),
          _isLogin,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const ValueKey("email"),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: "Email address"),
                    validator: (val) {
                      if (val!.isEmpty || val.length < 8) {
                        return 'Au moins 7 caracteres.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey("password"),
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (val) {
                      if (val!.isEmpty || val.length < 7) {
                        return 'Password must be at least 7 characters.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                  ),
                  if (!_isLogin) ...[
  /*                  TextFormField(
                      key: const ValueKey("matricule"),
                      decoration: const InputDecoration(labelText: "Matricule"),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a valid matricule.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userMatricule = value!;
                      },
                    ),*/
                    TextFormField(
                      key: const ValueKey("nom"),
                      decoration: const InputDecoration(labelText: "Nom"),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a valid nom.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userNom = value!;
                      },
                    ),
                  /*  TextFormField(
                      key: const ValueKey("prenom"),
                      decoration: const InputDecoration(labelText: "Prenom"),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter a valid prenom.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userPrenom = value!;
                      },
                    ),*/
                  ],
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    onPressed: (() {
                      _submit();
                    }),
                    child: Text(_isLogin ? "Login" : "Signup"),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                        _isLogin ? "Create new account" : "I have an account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}