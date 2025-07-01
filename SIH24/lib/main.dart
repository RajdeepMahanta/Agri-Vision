import 'package:agriplant/pages/home_page.dart';
import 'package:agriplant/pages/landing_page.dart';
import 'package:agriplant/pages/seller/seller_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Widget _screen = const Scaffold(body: Center(child: CircularProgressIndicator()));

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _screen =  LandingPage());
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        String userType = userDoc.get('userType');
        if (userType == 'Farmer') {
          setState(() => _screen = const HomePage());
        } else if (userType == 'Seller') {
          setState(() => _screen = const SellerHome());
        } else {
          setState(() => _screen = LandingPage());
        }
      } else {
        setState(() => _screen = LandingPage());
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => _screen = LandingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _screen;
  }
}
