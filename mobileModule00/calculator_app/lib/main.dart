import 'package:math_expressions/math_expressions.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AppCalculator());
}

class AppCalculator extends StatelessWidget {
  const AppCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false,
    home: Calculator());
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

  static const operators = {'+', '-', 'x', '/'};

  void ButtonPressed(String value)  {
    if (value.trim().isEmpty) return;

    setState(() {
      if (value == 'AC') {
        expression = "0";
        result = "0";
        return;
      }

      if (value == 'C') {
        if (expression.length > 1) {
          expression = expression.substring(0, expression.length - 1);
        } else {
          expression = "0";
        }
        return;
      }

      if (value == '=') {
        _calculateResult();
        return;
      }
      _appendValue(value);
    });
  }

  void _appendValue(String value) {
    if (expression == "0" && value != '.') {
      if (value == '+' || value == 'x' || value == '/') {
        expression += value;
        return;
      }
      expression = value;
      return;
    }

    if (value == '.') {
      final lastNumber = _getLastNumber();
      if (lastNumber.contains('.')) return;
    }

    final lastChar = expression[expression.length - 1];

    if (operators.contains(value)) {
      if (operators.contains(lastChar)) {
        if (value == '-') {
          if (lastChar == '-') {
            if (expression.length >= 2) {
              final char = expression[expression.length - 2];
              if (!operators.contains(char))
                expression += value;
            }
            return;
          }
          expression += value;
          return;
        }
        expression =
          expression.substring(0, expression.length - 1) + value;
        return;
      }
    }
    expression += value;
  }

  String _getLastNumber() {
    final regex = RegExp(r'(\d+\.?\d*)$');
    final match = regex.firstMatch(expression);
    return match?.group(0) ?? "";
  }

  void _calculateResult() {
    try {
      String exp = expression.replaceAll('x', '*');

      Parser parser = Parser();
      Expression parsedExpression = parser.parse(exp);

      double eval = parsedExpression.evaluate(EvaluationType.REAL, ContextModel(),);

      setState(() {
        if (eval.isInfinite || eval.isNaN) {
          result = "Error";
          return;
        }

        if (eval == eval.toInt()) {
          result = eval.toInt().toString();
        } else {
          result = eval.toString();
        }
      });
    } catch (_) {
      setState(() {
        result = "Error";
      });
    }
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    expression,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    buildButton('7'),
                    buildButton('8'),
                    buildButton('9'),
                    buildButton('C', color: Colors.orange),
                    buildButton('AC', color: Colors.red),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('4'),
                    buildButton('5'),
                    buildButton('6'),
                    buildButton('+', color: Colors.blue),
                    buildButton('-', color: Colors.blue),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('1'),
                    buildButton('2'),
                    buildButton('3'),
                    buildButton('x', color: Colors.blue),
                    buildButton('/', color: Colors.blue),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    buildButton('0'),
                    buildButton('.'),
                    buildButton('00'),
                    buildButton('=', color: Colors.green),
                    buildButton(' '),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget buildButton(String label, {Color? color}) {
    return Expanded(
      child: SizedBox(
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.grey,
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
