import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

import 'package:vidsummarizer/core/components.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/screens/main/main_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _formKey.currentState?.reset();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool _isValidPassword(String password) {
    return password.length > 6;
  }

  String? _usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_isValidEmail(value)) {
      return "This is not a valid email";
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    if (!_isValidPassword(value)) {
      return "This is not a valid password";
    }

    return null;
  }

  Future<void> _showLoading() {
    return showDialog(
      context: context,
      builder: (context) => loadingDialog(text: "Signing Up"),
      barrierDismissible: false,
    );
  }

  void _dismissLoading() {
    Navigator.of(context).pop();
  }

  Future<void> _signup() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _showLoading();

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await authManager.signup(username, email, password);

      _dismissLoading();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false
        );
      }
    }
    catch (error) {
      _dismissLoading();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          defaultSnackBar("There was an error creating your account. Try again later")
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primary,
      appBar: defaultBar(),
      body: createBody(),
    );
  }

  Widget createBody() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 42),
            Center(
              child: Text(
                "Create an account",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            SizedBox(height: 32),
            createFormField(
              label: "Enter your username",
              controller: _usernameController,
              validator: _usernameValidator,
              isEnd: false
            ),
            SizedBox(height: 16),
            createFormField(
              label: "Enter your email",
              controller: _emailController,
              validator: _emailValidator,
              isEnd: false
            ),
            SizedBox(height: 16),
            createFormField(
              label: "Enter your password",
              controller: _passwordController,
              validator: _passwordValidator,
              isEnd: true
            ),
            SizedBox(height: 62),
            InkWell(
              onTap: _signup,
              child: defaultButton(label: "Sign Up"),
            ),
          ]
        ),
      )
    );
  }

  Widget createFormField({
    required String label,
    required TextEditingController controller,
    required Function validator,
    required bool isEnd
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        return validator(value);
      },
      decoration: defaultDecoration(label: label),
      style: TextStyle(
        color: Colors.white,
      ),
      cursorColor: Colors.white,
      textInputAction: !isEnd ? TextInputAction.next : TextInputAction.done,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }

  Future<void> showError() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(

      )
    );
  }
}