import 'package:flutter/material.dart';

void main() {
  runApp(const AppCalculator());
}

class AppCalculator extends StatelessWidget {
  const AppCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Calculator());
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}
class _CalculatorState  extends State<Calculator>{
  String expression = "0";
  String result = "0";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Calculator'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: const Center(
          child: Text('Hola'),
        ),
      ),
    );
  }
}
