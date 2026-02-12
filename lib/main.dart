import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/welcome_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/patient/patient_page.dart';
import 'pages/patient/doctors_page.dart';
import 'pages/patient/my_appointments_page.dart';
import 'pages/patient/patient_profile_page.dart';
import 'pages/patient/patient_history_page.dart';
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
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/patient': (_) => const PatientPage(),
        '/patient/doctors': (_) => const DoctorsPage(),
        '/patient/my-appointments': (_) => const MyAppointmentsPage(),
        '/patient/profile': (_) => const PatientProfilePage(),
        '/patient/history': (_) => const PatientHistoryPage(),
        '/doctor': (_) => const DoctorPage(),
        '/admin': (_) => const AdminPage(),
      },
    );
  }
}
