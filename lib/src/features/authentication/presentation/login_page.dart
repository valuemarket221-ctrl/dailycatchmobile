import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _errorMessage;
  bool _isLogin = true; // To toggle between login and signup views

  Future<void> _submit() async {
    if (_isLogin) {
      _signIn();
    } else {
      _createAccount();
    }
  }

  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // AuthWrapper will handle navigation
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _createAccount() async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Create user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
           // Add other fields as necessary
        });
      }
      // AuthWrapper will handle navigation
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null; // Clear error message when switching forms
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _isLogin ? 'Bienvenue' : 'Créer un compte',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              if (!_isLogin)
                ...[
                  _buildTextField(_nameController, 'Nom complet'),
                  const SizedBox(height: 15),
                ], 
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
               if (!_isLogin)
                ...[
                  _buildTextField(_addressController, 'Adresse'),
                  const SizedBox(height: 15),
                  _buildTextField(_phoneController, 'Téléphone', keyboardType: TextInputType.phone),
                  const SizedBox(height: 15),
                ], 
              _buildTextField(_passwordController, 'Mot de passe', obscureText: true),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                  )
                ),
                onPressed: _submit,
                child: Text(_isLogin ? 'Se connecter' : 'Créer le compte'),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _toggleForm,
                child: Text(_isLogin ? 'Pas de compte ? Créez-en un' : 'Déjà un compte ? Connectez-vous'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
      return TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20)
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
      );
  }
}
