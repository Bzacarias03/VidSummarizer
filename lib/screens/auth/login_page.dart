import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'package:vidsummarizer/core/components.dart';
import 'package:vidsummarizer/core/constants.dart';
import 'package:vidsummarizer/screens/auth/signup_page.dart';
import 'package:vidsummarizer/screens/main/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool _isValidPassword(String password) {
    return password.length > 6;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    if (!_isValidEmail(value)) {
      return "This is not a valid email";
    }

    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your password";
    }
    if (!_isValidPassword(value)) {
      return "This is not a valid password";
    }

    return null;
  }

  Future<void> _showDialog() {
    return showDialog(
      context: context,
      builder: (context) => loadingDialog(text: "Signing in")
    );
  }

  void _dismissDialog() {
    Navigator.of(context).pop();
  }

  Future<void> _login() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _showDialog();

    final userEmail = _emailController.text.trim();
    final userPassword = _passwordController.text.trim();

    try {
      await authManager.login(userEmail, userPassword);

      _dismissDialog();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false
        );
      }
    }
    catch (error) {
      _dismissDialog();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          defaultSnackBar("There was an error logging in. Try again later")
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
                "Hi, Welcome Back!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              )
            ),
            SizedBox(height: 42),
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
              obscure: true,
              isEnd: true
            ),
            SizedBox(height: 32),
            InkWell(
              onTap: _login,
              child: defaultButton(label: "Login"),
            ),
            SizedBox(height: 52),
            Divider(
              height: 1,
              color: Color.fromARGB(35, 255, 255, 255),
            ),
            SizedBox(height: 52),
            Center(
              child: Text(
                "Don't have an account ?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () {
                _formKey.currentState?.reset();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignupPage())
                );
              },
              child: defaultButton(label: "Sign Up"),
            )
          ]
        )
      )
    );
  }

  Widget createFormField({
    required String label,
    required TextEditingController controller,
    required Function validator,
    required bool isEnd,
    bool obscure = false
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
      obscureText: obscure,
      textInputAction: !isEnd ? TextInputAction.next : TextInputAction.done,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    );
  }
}