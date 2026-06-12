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

  void ButtonPressed(String value)  {
    print("Button pressed: $value");
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Calculator'),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(
          child: Column(
            children: [
              TextField(
                readOnly: true,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: expression,
                  hintStyle: const TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
              TextField(
                readOnly: true,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: result,
                  hintStyle: const TextStyle(color: Colors.white, fontSize: 32),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('C'),
                    buildButton('AC'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('+'),
                    buildButton('-'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('x'),
                    buildButton('/'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('00'),
                    buildButton('='),
                    buildButton(' '),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget buildButton(String label) {
    return Expanded(
      child: SizedBox(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            minimumSize: Size.zero,
          ),
          onPressed: label.isEmpty ? null : () => ButtonPressed(label),
          child: Text(label, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}