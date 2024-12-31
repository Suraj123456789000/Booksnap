import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() async {
  AwesomeNotifications().initialize(
    null, // icon for your app notification
    [
      NotificationChannel(
        channelKey: 'key1',
        channelName: 'Proto Coders Point',
        channelDescription: "Notification example",
        defaultColor: Color(0XFF9050DD),
        ledColor: Colors.white,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      )
    ],
  );
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOOKSNAP',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/data': (context) => const DataPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });

    return const Scaffold(
      body: Center(
        child: Text(
          'BOOKSNAP',
          style: TextStyle(
              fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFF0984E3),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> handleLogin(BuildContext context) async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential.user != null) {
          Navigator.of(context)
              .pushNamed('/data', arguments: userCredential.user!.email);
        }
      } else {
        _showErrorDialog(context, 'Please enter both email and password');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showErrorDialog(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(context, 'Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        _showErrorDialog(context, 'The email address is badly formatted.');
      } else {
        _showErrorDialog(
            context, e.message ?? 'Login failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog(context, 'An unknown error occurred. Please try again.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            color: const Color(0xFF0984E3),
            child: const Center(
              child: Text(
                'BOOKSNAP',
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                const Text('Enter Email:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Enter Password:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => handleLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0984E3),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final TextEditingController issueDateController = TextEditingController();
  TimeOfDay? selectedTime;
  String returnDate = '';

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
          title: Text('Welcome, $email!'),
          backgroundColor: const Color(0xFF0984E3)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Enter Issue Date (dd-MM-yyyy):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            TextField(
              controller: issueDateController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'dd-MM-yyyy'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(selectedTime == null
                  ? 'Select Notification Time'
                  : 'Selected Time: ${selectedTime!.format(context)}'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleDateSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0984E3),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 18)),
            ),
            if (returnDate.isNotEmpty)
              Text('Your Return Date is: $returnDate',
                  style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void handleDateSubmit() async {
    try {
      final issueDate =
          DateFormat('dd-MM-yyyy').parse(issueDateController.text);
      final returnDateObj = issueDate.add(const Duration(days: 7));

      // Combine return date and time for the notification
      final returnDateTime = DateTime(
        returnDateObj.year,
        returnDateObj.month,
        returnDateObj.day,
        selectedTime?.hour ?? 0,
        selectedTime?.minute ?? 0,
      );

      // Get local time zone
      String timeZone =
          await AwesomeNotifications().getLocalTimeZoneIdentifier();
      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          // Request permission to send notifications
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
      AwesomeNotifications().initialize(
        null, // Your app icon
        [
          NotificationChannel(
            channelKey: 'key1',
            channelName: 'Book Return Notifications',
            channelDescription:
                'Notification channel for book return reminders',
            defaultColor: Color(0XFF9050DD),
            ledColor: Colors.white,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          )
        ],
      );

      final now = DateTime.now();
      final testDateTime = now.add(
          const Duration(seconds: 10)); // Trigger 10 seconds later for testing

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'key1',
          title: 'Due Date Reminder',
          body: 'Today you need to return you book to Library',
        ),
        schedule: NotificationCalendar.fromDate(date: testDateTime),
      );

      // Update the return date
      setState(() {
        returnDate = DateFormat('dd-MM-yyyy').format(returnDateObj);
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Please enter a valid date and time'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
