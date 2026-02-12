import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/patient_page.dart';
import 'pages/doctor_page.dart';
import 'pages/admin_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WelcomePage(),
      routes: {
        "/login": (_) => const LoginPage(),
        "/admin": (_) => const AdminPage(),
        "/patient": (_) => const PatientPage(),
        "/doctor": (_) => const DoctorPage(),
      },
    );
  }
}
