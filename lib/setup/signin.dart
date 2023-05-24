import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = '';
  String _password = '';

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      print('Form is Valid Email $_email Password: $_password');
      return true;
    } else {
      print('Form is NOT Valid');
    }
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          UserCredential user = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);
          print('Signed In: $user.uid');
        } else {
          UserCredential user = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password);
        }
      } on Exception catch (e) {
        print('Error $e');
      }
    }
  }

  void moveToRegister() {
    _formKey.currentState?.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    setState(() {
      _formType = FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: buildAppBar(),
        ),
        body: Container(
            padding: EdgeInsets.all(36.0),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildInputs() + buildSubmitButtons(),
                ))));
  }

  List<Widget> buildInputs() {
    return [
      TextFormField(
        decoration: InputDecoration(labelText: 'Email'),
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value!,
      ),
      TextFormField(
        decoration: InputDecoration(labelText: 'Password'),
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value!,
        obscureText: true,
      ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.login) {
      return [
        ElevatedButton(
          onPressed: validateAndSubmit,
          child: Text('Login'),
        ),
        ElevatedButton(
            onPressed: moveToRegister, child: Text('Create an Account')),
      ];
    } else {
      return [
        ElevatedButton(
          onPressed: validateAndSubmit,
          child: Text('Create an Account'),
        ),
        ElevatedButton(
            onPressed: moveToLogin,
            child: Text('Already have an Account? Login')),
      ];
    }
  }

  Widget buildAppBar() {
    if (_formType == FormType.login) {
      return Text('Login');
    } else {
      return Text('Registration Form');
    }
  }
}
