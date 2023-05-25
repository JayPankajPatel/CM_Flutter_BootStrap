import 'package:flutter/material.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({required this.auth, required this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
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
          String userId =
              await widget.auth.signInWithEmailandPassword(_email, _password);
          print('Signed In: $userId');
        } else {
          String userId = await widget.auth
              .createUserWithEmailandPassword(_email, _password);
          print('Registered User: $userId');
        }
        widget.onSignedIn();
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
