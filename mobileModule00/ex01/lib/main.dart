import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  String text = 'A simple text';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  backgroundColor: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (text == 'A simple text') {
                      text = 'Hello World!';
                    } else {
                      text = 'A simple text';
                    }
                  });
                },
                child: const Text(
                  'Click me',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}