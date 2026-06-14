import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const AppCalculator());
}

class AppCalculator extends StatelessWidget {
  const AppCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String expression = "0";
  String result = "0";

  void ButtonPressed(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        return;
      }

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

      if (expression == "0") {
        expression = value;
      } else {
        expression += value;
      }
    });
  }

  void _calculateResult() {
    try {
      // math_expressions usa * en lugar de x
      String exp = expression.replaceAll('x', '*');

      Parser parser = Parser();
      Expression parsedExpression = parser.parse(exp);

      double eval = parsedExpression.evaluate(
        EvaluationType.REAL,
        ContextModel(),
      );

      // División entre 0
      if (eval.isInfinite || eval.isNaN) {
        result = "Error";
        return;
      }

      // Mostrar enteros sin .0
      if (eval == eval.toInt()) {
        result = eval.toInt().toString();
      } else {
        result = eval.toString();
      }
    } catch (_) {
      // Expresiones incompletas o inválidas
      result = "Error";
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

            // Expresión
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

            // Resultado
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            minimumSize: Size.zero,
          ),
          onPressed: label.trim().isEmpty
              ? null
              : () => ButtonPressed(label),
          child: Text(
            label,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}