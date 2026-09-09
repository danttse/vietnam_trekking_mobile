import 'package:flutter/material.dart';

void main() {
  runApp(const VietnamTrekkingApp());
}

class VietnamTrekkingApp extends StatelessWidget {
  const VietnamTrekkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vietnam Trekking',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text(
            'Vietnam Trekking\nĐang xây dựng...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
